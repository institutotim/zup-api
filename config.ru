# This file is used by Rack-based servers to start the application.
require ::File.expand_path('../application',  __FILE__)

ENV['DISABLE_MEMORY_CACHE'] = 'false'

run ZupServer
