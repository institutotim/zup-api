SIDEKIQ_USER = ENV['SIDEKIQ_USER'].freeze
SIDEKIQ_PASSWORD = ENV['SIDEKIQ_PASSWORD'].freeze
REDIS_NAMESPACE = ENV['REDIS_NAMESPACE'] || 'zup'

Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] || 'redis://127.0.0.1:6379', namespace: REDIS_NAMESPACE }

  # Sidekiq-cron Scheduler
  schedule_file = 'config/schedule.yml'

  if File.exists?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash(YAML.load_file(schedule_file))
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] || 'redis://127.0.0.1:6379', namespace: REDIS_NAMESPACE }
end

require 'sidekiq/rails'
Sidekiq.hook_rails!
