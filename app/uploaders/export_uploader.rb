class ExportUploader < CarrierWave::Uploader::Base
  def store_dir
    if Application.config.env.test?
      "uploads/test/exports/#{model.id}/"
    else
      "uploads/exports/#{model.id}/"
    end
  end

  def filename
    return unless original_filename.present?

    "#{model.kind_humanize}_#{model.created_at.strftime("%d-%m-%Y_%H-%M-%S")}.csv"
  end
end
