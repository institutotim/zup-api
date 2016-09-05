case Application.config.env.to_sym
when :production || :staging
  if ENV['SENTRY_DSN_URL']
    require 'raven'
    Raven.configure do |config|
      config.environments = %w(production staging)
      config.dsn = ENV['SENTRY_DSN_URL']
    end
  end
when :development
  class Raven
    def self.capture_exception(e, _options = {})
      fail e
    end
  end
else
  class Raven
    def self.capture_exception(*_args)
      # Do nothing
    end
  end
end
