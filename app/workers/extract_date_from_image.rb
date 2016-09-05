class ExtractDateFromImage
  include Sidekiq::Worker

  sidekiq_options retry: false, unique: :until_executed

  def perform(image_id)
    if image = Reports::Image.find_by(id: image_id)

      if File.exists?(image.image.path)
        image_path = image.image.path
      else
        tempfile = Tempfile.new('image').tap do |file|
          uri = URI.parse(image.image_url)

          file.binmode
          file.write(uri.read)
          file.close
        end

        image_path = tempfile.path
      end

      data = EXIFR::JPEG.new(image_path)

      if data.exif? && data.date_time
        image.date = data.date_time
        image.save
      end
    end
  rescue => exception
    ErrorHandler.capture_exception(exception, :info)
  end
end
