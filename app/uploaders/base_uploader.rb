class BaseUploader < CarrierWave::Uploader::Base
  def content_type_whitelist
    [/image\//]
  end
end
