class ImageUploader < BaseUploader
  include CarrierWave::MiniMagick

  version :high do
    process resize_and_optimize: [800, 800]
  end

  version :low do
    process resize_and_optimize: [400, 400]
  end

  version :thumb do
    process resize_and_optimize: [150, 150]
  end

  def store_dir
    if Application.config.env.test?
      'uploads/test/'
    else
      'uploads/'
    end
  end

  # Resize image and convert to jpeg format
  def resize_and_optimize(width, height)
    manipulate! do |img|
      img.format('jpg') do |c|
        c.quality '70'
        c.resize "#{width}x#{height}"
      end

      img
    end
  end
end
