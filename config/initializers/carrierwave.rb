if (Application.config.env.production?) && !(ENV['AWS_ACCESS_KEY_ID'].nil? || ENV['AWS_SECRET_ACCESS_KEY'].nil?)
  CarrierWave.configure do |config|
    config.fog_credentials = {
        provider: 'AWS',
        aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    }

    config.fog_directory = ENV['AWS_DEFAULT_IMAGE_BUCKET']
    config.storage = :fog
    config.cache_dir = '/tmp'
  end
else
  CarrierWave.configure do |config|
    config.storage = :file
    config.asset_host = ENV['ASSET_HOST_URL']
    config.root = "#{Application.config.root}/public"
    config.cache_dir = '/tmp'

    if Application.config.env.test?
      config.enable_processing = false
    else
      config.enable_processing = true
    end
  end
end

CarrierWave.root = "#{Application.config.root}/public"
