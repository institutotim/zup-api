class PinUploader < BaseUploader
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
      "uploads/test/#{model.class.name.downcase.gsub("::", "/")}/#{model.id}/pins/"
    else
      "uploads/#{model.class.name.downcase.gsub("::", "/")}/#{model.id}/pins/"
    end
  end

  def blank?
    to_s.blank?
  end

  def filename
    "#{super.chomp(File.extname(super))}.png" if original_filename.present?
  end

  def merge_with_base(_platform)
    base_file = 'public/base/marker_categoria_invenrio_base@2x.png'

    manipulate! do |_img|
      base_image = MiniMagick::Image.open(File.join(Application.config.root, base_file))

      # Tint the color
      base_image.combine_options do |cmd|
        cmd.colorspace 'Gray'
        cmd.fill model.color
        cmd.tint 50
        cmd.colorize '80,80,80,0'
      end

      result = base_image
      result = yield(result) if block_given?
      result
    end
  end

  def resize_to_half
    manipulate! do |img|
      img.resize '50%'
      img = yield(img) if block_given?
      img
    end
  end
end
