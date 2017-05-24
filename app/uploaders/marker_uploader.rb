class MarkerUploader < BaseUploader
  include CarrierWave::MiniMagick

  version :retina do
    version :web do
      process merge_with_base: [:web]
    end

    version :mobile do
      process merge_with_base: [:mobile]
    end
  end

  version :default do
    version :web do
      process merge_with_base: [:web]
      process :resize_to_half
    end

    version :mobile do
      process merge_with_base: [:mobile]
      process :resize_to_half
    end
  end

  def store_dir
    if Application.config.env.test?
      "uploads/test/#{model.class.name.downcase.gsub("::", "/")}/#{model.id}/markers/"
    else
      "uploads/#{model.class.name.downcase.gsub("::", "/")}/#{model.id}/markers/"
    end
  end

  def filename
    "#{super.chomp(File.extname(super))}.png" if original_filename.present?
  end

  def blank?
    to_s.blank?
  end

  def merge_with_base(_platform)
    base_file = 'public/base/marker_categoria_relato_base@2x.png'

    manipulate! do |img|
      base_image = MiniMagick::Image.open(File.join(Application.config.root, base_file))

      img.format 'png'
      base_image.format 'png'

      # Tint the color
      base_image.combine_options do |cmd|
        cmd.colorspace 'Gray'
        cmd.fill model.color
        cmd.tint 50
        cmd.colorize '80,80,80,0'
      end

      # Resize
      img.resize '51x51'

      # Join images
      result = base_image.composite(img) do |c|
        c.compose 'Over'
        c.geometry '+19+20'
      end

      result = yield(result) if block_given?
      result
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
