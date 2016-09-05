if ENV['APPSIGNAL_PUSH_API_KEY']
  Appsignal.config = Appsignal::Config.new(
    Application.config.root,
    Application.config.env,
    name: ENV['APPSIGNAL_APP_NAME'] || 'zup-api'
  )

  Appsignal.start_logger(File.join(Application.config.root, 'log'))
  Appsignal.start
end
