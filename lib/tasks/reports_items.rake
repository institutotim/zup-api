namespace :reports do
  desc 'Set reports as overdue'
  task set_overdue: :environment do
    SetReportsOverdue.new.perform
  end

  desc 'Set protocol as id'
  task normalize_protocol: :environment do
    puts 'Updating protocol from reports...'

    Reports::Item.find_in_batches do |items|
      items.each do |item|
        if item.update(protocol: item.id)
          puts "Item ##{item.id} updated successfully!"
        else
          puts "Couldn't update item ##{item.id}: #{item.errors.full_messages.join(", ")}"
        end
      end
    end

    ActiveRecord::Base.connection.execute(
      <<-SQL
        SELECT setval('protocol_seq', (SELECT MAX(protocol) FROM reports_items));
      SQL
    )

    puts 'Reports updated!'
  end

  desc 'Exports all reports to CSV'
  task export: :environment do
    require 'ruby-progressbar'
    require 'parallel'
    ActiveRecord::Base.logger = nil

    directory = ENV['CSV_FILE_DIR'] || '.'

    reports = Reports::Item.includes(:category, :status, :assigned_user, :assigned_group)

    csv_file_name = "reports.#{Date.today.strftime("%Y%m%d")}.csv"

    CSV.open(File.join(directory, csv_file_name), 'wb') do |csv|
      csv << [
        'Nome da categoria',
        'Grupo Responsável',
        'Usuário responsável',
        'Email do responsável',
        'Protocolo',
        'Status',
        'Comentários',
        'Descrição',
        'Rua',
        'Número',
        'Bairro',
        'CEP',
        'Cidade',
        'Estado',
        'País',
        'Atrasado?',
        'Em atraso desde',
        'Finalizado em',
        'Criado em'
      ]

      Parallel.each(reports.find_in_batches, in_processes: 2, progress: 'Exporting reports items...') do |reports_batch|
        reports_batch.each do |r|
          finished_at = if r.status.for_category(r.category).final?
                          r.status_history.find_by(new_status_id: r.status.id).try(:created_at)
                        end

          csv << [
            r.category.title,
            r.assigned_group.try(:name),
            r.assigned_user.try(:name),
            r.assigned_user.try(:email),
            r.protocol,
            r.status.title,
            r.comments_count,
            r.description,
            r.address,
            r.number,
            r.district,
            r.postal_code,
            r.city,
            r.state,
            r.country,
            r.overdue,
            r.overdue_at,
            finished_at,
            r.created_at
          ]
        end
      end

      puts "Done! File #{csv_file_name} written successfully."
    end
  end

  desc 'Geocode items with incorrect lat and long (or nil)'
  task geocode_incorrect_items: :environment do
    require 'ruby-progressbar'
    ActiveRecord::Base.logger = nil

    latitude = ENV['LATITUDE']
    longitude = ENV['LONGITUDE']
    distance = ENV['DISTANCE'] # IN METERS

    unless latitude && longitude && distance
      fail 'You need to define LATITUDE, LONGITUDE and DISTANCE variables'
    end

    # Get all items with position nil OR with the latitude and longitude
    latlon = "POINT(#{ENV["LONGITUDE"]} #{ENV["LATITUDE"]})"
    result = Reports::Item.where("position IS NULL OR ST_DWithin(
                                    ST_GeomFromText('#{latlon}', 4326)::geography,
                                    reports_items.position, #{distance.to_i}
                                  )")

    progress = ProgressBar.create(
      format: '%a %e %bᗧ%i %p%% %t',
      progress_mark: ' ',
      remainder_mark: '･',
      total: result.count
    )

    puts "Total reports found: #{result.count}"

    result.find_in_batches do |items|
      items.each do |item|
        begin
          GeocodeReportsItem.new.perform(item.id)
        rescue => e
          puts "Report item ##{item.id} could'nt be geocoded: #{e.message}"
        end

        progress.increment
      end
    end

    progress.finish
  end

  namespace :webhook do
    namespace :conciliate do
      desc 'Imports `.json` file to conciliate the data'
      task in: :environment do
        require 'ruby-progressbar'
        ActiveRecord::Base.logger = nil

        file = ENV['JSON_FILE']

        fail 'JSON_FILE env var is necessary, point to the file to import' unless file
        fail 'Webhook is not enabled for this application' unless Webhook.enabled?

        file = File.open(file, 'r')

        # Do the conciliation
        data = Oj.load(file.read)

        progress = ProgressBar.create(
                                      format: '%a %e %bᗧ%i %p%% %t',
                                      progress_mark: ' ',
                                      remainder_mark: '･',
                                      total: data['items'].size
                                     )

        data['items'].each do |report|
          Reports::ConciliateFromWebhook.new(report).conciliate!
          progress.increment
        end

        progress.finish
      end

      desc 'Exports `.json` file for conciliation'
      task out: :environment do
        file = ENV['JSON_FILE']

        fail 'JSON_FILE env var is necessary, point to the file to import' unless file
        fail 'Webhook is not enabled for this application' unless Webhook.enabled?

        categories = Webhook.integration_categories

        File.open(file, 'w') do |file|
          file.write '{ "items": ['

          i = 1
          items = Reports::Item.includes(:user, :status, :category, comments: [:author]).where(category: categories)
          total = items.count
          items.find_in_batches do |items|
            items.each do |item|
              file.write Reports::SerializeToWebhook.new(item).serialize.to_json
              file.write ',' if i >= 1 && i < total

              i += 1
            end
          end

          file.write '] }'
        end

        puts 'Done! File written.'
      end
    end
  end
end
