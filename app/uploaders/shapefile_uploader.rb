class ShapefileUploader < CarrierWave::Uploader::Base
  def store_dir
    if Application.config.env.test?
      "uploads/test/#{model.class.name.downcase.gsub("::", "/")}/#{model.id}/shapefiles/"
    else
      "uploads/#{model.class.name.downcase.gsub("::", "/")}/#{model.id}/shapefiles/"
    end
  end

  def filename
    "shapefile.#{file.extension}" if original_filename.present?
  end
end
