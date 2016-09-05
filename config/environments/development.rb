# to solve autoloading issues
Application.eager_load!

ActiveRecord::Base.logger = Logger.new(STDOUT)

class CacheStore
  def fetch(*_args)
    yield
  end

  def delete(*_args)
    nil
  end

  def delete_matched(*_args)
    nil
  end
end

Application.config.cache = CacheStore.new
