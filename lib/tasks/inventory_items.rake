namespace :inventory_items do
  desc 'Unlock inventory items'
  task unlock: :environment do
    UnlockInventoryItems.new.perform
  end

  desc 'Import inventory items from csv'
  task import_from_csv: :environment do
    require 'parallel'
    require 'ruby-progressbar'

    # Obligatory env vars for the importer
    missing_keys = []
    %w(CSV_FILE CATEGORY_ID MAPQUEST_API_KEY).each do |env_var|
      missing_keys << env_var unless ENV[env_var].present?
    end

    if missing_keys.any?
      fail "You need to provide the following env vars: #{missing_keys.join(", ")}"
    end

    file_name = ENV['CSV_FILE']
    category_id = ENV['CATEGORY_ID']

    csv = CSV.parse(File.read(file_name)).first(150)
    fields_labels = csv.shift

    importer = Inventory::ImportFromCSVRow.new(category_id, fields_labels)

    Parallel.each(csv, in_threads: 1, progress: 'Importing items') do |row|
      ActiveRecord::Base.connection_pool.with_connection do
        Inventory::Item.transaction do
          importer.import!(row)
        end
      end
    end
  end
end
