class ErrorHandler
  class Level
    def to_s
      name
    end

    def name
      self.class.name.split('::').last.downcase
    end

    def send_errors?
      false
    end
  end

  class Debug < Level;   end
  class Info < Level;    end
  class Warning < Level; end

  class Fatal < Level
    def send_errors?
      true
    end
  end

  class Error < Level
    def send_errors?
      true
    end
  end

  attr_reader :engine, :level

  def self.capture_exception(exception, level = :error, environment = nil)
    options = {}

    if environment
      options.deep_merge!(
        params: environment.safe_params,
        token: environment.app_token,
        user: environment.current_user,
        headers: environment.headers,
        path: environment.request.path
      )

      if ENV['VIRTUAL_HOST']
        options[:virtual_host] = ENV['VIRTUAL_HOST']
      end
    end

    instance = new(level)
    instance.capture_exception(exception, options)
  end

  def initialize(level, engine = nil)
    @engine = engine

    if defined?(Raven)
      @engine ||= Raven
    end

    self.level = level
  end

  def logger
    ZUP::API.logger
  end

  def capture_exception(exception, options = {})
    if engine.respond_to?(:capture_exception)
      engine.capture_exception(exception, build_params(options))
    end

    raise_exception(exception)
    log_exception(exception)
  end

  def raise_exception(exception)
    fail(exception) if raise_exceptions?
  end

  def log_exception(exception)
    logger.error(exception) if level.send_errors?
  end

  def raise_exceptions?
    ENV['RAISE_ERRORS']
  end

  def level=(new_level)
    @level =
      case new_level
      when Level then new_level
      else self.class.const_get(new_level.to_s.capitalize).new
      end
  end

  private

  def build_params(options = {})
    params = { level: level.name }

    unless options.empty?
      params.deep_merge!(
        extra: {
          token: options[:token],
          params: options[:params],
          headers: options[:headers],
          path: options[:path]
        }
      )
    end

    if (user = options.delete(:user))
      params.deep_merge!(
        user: {
          id: user.id,
          email: user.email
        }
      )
    end

    params
  end
end
