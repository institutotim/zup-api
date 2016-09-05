SIDEKIQ_USER = ENV['SIDEKIQ_USER'].freeze
SIDEKIQ_PASSWORD = ENV['SIDEKIQ_PASSWORD'].freeze

Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] || 'redis://127.0.0.1:6379', namespace: 'zup' }

  # Sidekiq-cron Scheduler
  schedule_file = 'config/schedule.yml'

  if File.exists?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash(YAML.load_file(schedule_file))
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] || 'redis://127.0.0.1:6379', namespace: 'zup' }
end

require 'sidekiq/rails'
Sidekiq.hook_rails!
