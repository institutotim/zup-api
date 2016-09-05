class ImportShapefile
  include Sidekiq::Worker

  def perform(perimeter_id)
    if perimeter = Reports::Perimeter.find(perimeter_id)
      if File.exists?(perimeter.shp_file.path)
        shp_path = perimeter.shp_file.path
      else
        full_path = "#{Application.config.root}/tmp/#{SecureRandom.hex(9)}"

        shp_file = File.new("#{full_path}.shp", 'w+').tap do |file|
          uri = URI.parse(perimeter.shp_file_url)
          file.binmode
          file.write(uri.read)
          file.close
        end

        shx_file = File.new("#{full_path}.shx", 'w+').tap do |file|
          uri = URI.parse(perimeter.shx_file_url)
          file.binmode
          file.write(uri.read)
          file.close
        end

        shp_path = shp_file.path
      end

      begin
        RGeo::Shapefile::Reader.open(shp_path) do |shapefile|
          if shapefile.num_records == 1
            geometry = shapefile.next

            perimeter.geometry = geometry.geometry
            perimeter.status = 'imported'
          else
            perimeter.status = 'invalid_quantity'
          end
        end
      rescue => exception
        perimeter.status = 'invalid_file'

        ErrorHandler.capture_exception(exception)
      end

      perimeter.save!
    end
  ensure
    if perimeter && perimeter.pendent?
      perimeter.update!(status: 'unknown_error')
    end

    FileUtils.rm(["#{full_path}.shp", "#{full_path}.shx"], force: true) if full_path
  end
end
