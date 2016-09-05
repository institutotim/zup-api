class IconUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  BASE_FILE = 'public/base/bola_categoria_relato_base@2x.png'

  version :retina do
    version :web do
      version :active do
        process merge_with_base: [:web]
      end

      version :disabled do
        process merge_with_base: [:web, true]
      end
    end

    version :mobile do
      version :active do
        process merge_with_base: [:mobile]
      end

      version :disabled do
        process merge_with_base: [:mobile, true]
      end
    end
  end

  version :default do
    version :web do
      version :active do
        process merge_with_base: [:web]
        process :resize_to_half
      end

      version :disabled do
        process merge_with_base: [:web, true]
        process :resize_to_half
      end
    end

    version :mobile do
      version :active do
        process merge_with_base: [:mobile]
        process :resize_to_half
      end

      version :disabled do
        process merge_with_base: [:mobile, true]
        process :resize_to_half
      end
    end
  end

  def store_dir
    if Application.config.env.test?
      "uploads/test/#{model.class.name.downcase.gsub("::", "/")}/#{model.id}/icons/"
    else
      "uploads/#{model.class.name.downcase.gsub("::", "/")}/#{model.id}/icons/"
    end
  end

  def filename
    "#{super.chomp(File.extname(super))}.png" if original_filename.present?
  end

  def blank?
    to_s.blank?
  end

  def merge_with_base(platform, disabled = false)
    manipulate! do |img|
      img.format 'png'

      unless disabled
        ball_color = model.color
      else
        if platform == :mobile
          ball_color = '#e5e5e5'
          icon_color = '#f3f3f3'
        else
          ball_color = '#262626'
          icon_color = '#333333'
        end

        img.fill icon_color
      end

      base_image = MiniMagick::Image.open(File.join(Application.config.root, BASE_FILE))

      base_image.format 'png'

      # Tint the color
      base_image.combine_options do |cmd|
        cmd.colorspace 'Gray'
        cmd.fill ball_color
        cmd.tint 50
        cmd.colorize '80,80,80,0'
      end

      result = base_image.composite(img) do |c|
        c.gravity 'center'
      end

      result = yield(result) if block_given?
      result
    end
  end

  def convert_to_disabled
    manipulate! do |img|
      img.format 'png'
      img.resize '50%'
      img = yield(img) if block_given?
      img
    end
  end

  def resize_to_half
    manipulate! do |img|
      img.format 'png'
      img.resize '50%'
      img = yield(img) if block_given?
      img
    end
  end
end
