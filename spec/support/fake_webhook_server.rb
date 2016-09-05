require 'bundler'
Bundler.require :default, :development

require 'sinatra'

LOG_PATH = File.dirname(__FILE__)

module Application
  def self.logger
    @logger ||= Logger.new(
      File.join(LOG_PATH, 'fake_webhook_server.log')
    )
  end
end

# Sinatra configuration
set :port, 7777

post '/' do
  # Only log the parameters
  Application.logger.info "Received POST with params: #{params.inspect}"
  status 200
  body 'OK'
end

delete '/' do
  # Only log the parameters
  Application.logger.info "Received DELETE with params: #{params.inspect}"
  status 200
  body 'OK'
end

put '/' do
  # Only log the parameters
  Application.logger.info "Received PUT with params: #{params.inspect}"
  status 200
  body 'OK'
end
