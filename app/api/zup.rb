require 'grape-swagger'
require 'garner/mixins/rack'
require 'oj'
require 'will_paginate/array'
require 'rack/test'
require 'action_controller/metal/strong_parameters'
require 'action_dispatch/http/parameter_filter'
require 'version'

module ZUP
  class API < Grape::API
    use Rack::ConditionalGet
    use Rack::ETag
    use Audit

    if ENV['LOG_REQUESTS']
      use GrapeLogging::Middleware::RequestLogger, logger: logger, include: [GrapeLogging::Loggers::Response.new,
                                                                           GrapeLogging::Loggers::FilterParameters.new([:password]),
                                                                           GrapeLogging::Loggers::ClientEnv.new,
                                                                           GrapeLogging::Loggers::RequestHeaders.new]
    end

    helpers Garner::Mixins::Rack

    # This is necessary because `grape-swagger`
    # gem adds this, thus causing CORS error
    # when trying to load externally the documentation
    # endpoint.
    after do
      header.delete('Access-Control-Allow-Origin')
      header.delete('Access-Control-Request-Method')
    end

    mount Users::API
    mount Groups::API
    mount Permissions::API
    mount Inventory::API
    mount Reports::API
    mount Search::API
    mount Flows::API
    mount Cases::API
    mount FeatureFlags::API
    mount Utils::API
    mount Auth::API
    mount Services::API
    mount BusinessReports::API
    mount Settings::API
    mount ChatMessages::API
    mount ChatRooms::API
    mount Notifications::API
    mount Terminology::API
    mount Namespaces::API
    mount Exports::API
    mount EventLogs::API

    add_swagger_documentation(hide_format: true)

    get '/' do
      content_type 'text/plain'
      body "ZUP API version #{ZupApi::VERSION}\nStatus: OK"
    end
  end
end
