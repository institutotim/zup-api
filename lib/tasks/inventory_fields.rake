require 'parallel'

namespace :inventory_fields do
  task migrate_available_values: :environment do
    inventory_fields = Inventory::Field.where(
      "available_values IS NOT NULL AND available_values != '{}'"
    )

    inventory_fields.each do |field|
      field.available_values.each do |option_value|
        field.field_options.find_or_create_by(value: option_value)
      end

      field.field_options.reload

      # Update reference for inventory item data
      data = Inventory::ItemData.where(inventory_field_id: field.id)

      Parallel.each(data, in_threads: 4) do |_item_data|
        data.each do |item_data|
          content = item_data.read_attribute(:content)

          next unless content

          selected_options = content.map do |c|
            next unless c
            field.field_options.find_by(value: c)
          end.compact

          item_data.selected_options = selected_options
          item_data.save!

          puts "Migrated information about item data ##{item_data.id}"
        end
      end
    end
  end
end
