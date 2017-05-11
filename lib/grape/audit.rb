class Audit < Grape::Middleware::Base
  LOG_METHODS = %w(POST PUT PATCH DELETE)

  FILTERED_PARAMS = %w(password password_confirmation icon marker image
    attachment pin shp_file shx_file images)

  def after
    if audit?
      EventLog.create(
        user: environment.current_user,
        namespace: environment.current_namespace,
        url: request.path,
        headers: environment.headers,
        request_body: filtered_params,
        request_method: request.request_method
      )
    end

    nil
  end

  private

  def filtered_params
    params = request.params.symbolize_keys

    FILTERED_PARAMS.each do |fp|
      params.delete(fp.to_sym)
    end

    params
  end

  def environment
    env['api.endpoint']
  end

  def request
    environment.request
  end

  def audit?
    LOG_METHODS.include?(request.request_method)
  end
end
