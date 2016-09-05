class FilesUploader < CarrierWave::Uploader::Base
  def store_dir
    if Application.config.env.test?
      'uploads/test/'
    else
      'uploads/'
    end
  end
end
