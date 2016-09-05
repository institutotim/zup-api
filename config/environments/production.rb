Application.eager_load!

Application.config.cache = ActiveSupport::Cache::RedisStore.new
