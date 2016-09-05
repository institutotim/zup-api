module Zup
  module Initialization
    REQUIRED_ENVIROMENT_VARIABLES = %w[
      API_URL SMTP_ADDRESS SMTP_PORT SMTP_USER
      SMTP_PASS SMTP_TTLS SMTP_AUTH REDIS_URL
      WEB_URL SIDEKIQ_USER SIDEKIQ_PASSWORD
    ]

    # Makes sure everything we need to run this is available on the environment
    def self.assert_required_environment_variables!
      missing_vars = []

      REQUIRED_ENVIROMENT_VARIABLES.each do |required_var|
        if ENV[required_var].nil? || ENV[required_var].blank?
          missing_vars.push required_var
        end
      end

      if missing_vars.size > 0
        puts 'Missing enviroment variables: ' + missing_vars.join(', ')
        exit! 1
      end
    end
  end
end

Zup::Initialization.assert_required_environment_variables! unless Application.config.env.test? || File.basename($0) == 'rake'
