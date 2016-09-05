ruby '2.2.2'

source 'https://rubygems.org'

gem 'activerecord', '4.1.10'
gem 'activesupport', '4.1.10'
gem 'actionmailer', '4.1.10'
gem 'actionpack', '4.1.10'
gem 'pg'
gem 'pg_search'
gem 'rgeo', '0.3.20'
gem 'rgeo-shapefile'
gem 'activerecord-postgis-adapter'
gem 'bcrypt', '~> 3.1.7'
gem 'grape', '~> 0.14.0'
gem 'grape-entity', github: 'intridea/grape-entity', ref: '48e5be7df9e362edc452332375e9397b12abdd45'
gem 'grape-swagger'
gem 'cancancan', '~> 1.10'
gem 'textacular', '~> 3.0'
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
gem 'armor'
gem 'carrierwave', '~> 0.10.0'
gem 'fog', '~> 1.28.0'
gem 'rack-cors', require: 'rack/cors'
gem 'squeel'
gem 'will_paginate', require: false
gem 'api-pagination', require: false
gem 'mini_magick'
gem 'settingslogic'
gem 'sidekiq', '4.1.4'
gem 'sidekiq-cron'
gem 'sidekiq-unique-jobs'
gem 'sinatra', '>= 1.3.0', require: nil
gem 'oj'
gem 'oj_mimic_json'
gem 'garner'
gem 'brcpfcnpj'
gem 'paper_trail', '~> 4.0.0.beta2'
gem 'pushmeup', github: 'alarionov/pushmeup', ref: 'fd43ba21ef3bbe8053f8878f9f800f7185b98156'
gem 'atomic_arrays'
gem 'parallel', require: false
gem 'ruby-progressbar', require: false
gem 'sentry-raven', require: false
gem 'foreman'
gem 'god'
gem 'minitest'
gem 'dotenv'
gem 'grape_logging'
gem 'require_all'
gem 'redis-activesupport'
gem 'redlock'
gem 'geocoder'
gem 'axlsx', require: false
gem 'yell'
gem 'slackhook'
gem 'factory_girl', '~> 4.3.0', require: false
gem 'ffaker', require: false
gem 'cpf_faker', require: false
gem 'exifr'
gem 'dentaku'
gem 'cubes', github: 'ntxcode/cubes'

group :development, :test do
  gem 'rspec', '~> 3.2.0'
  gem 'awesome_print'
  gem 'pry-byebug', '1.3.3'
  gem 'pry-remote'
  gem 'timecop'
end

group :development do
  gem 'thin'
  gem 'passenger', '~> 5.0.30'
end

group :test do
  gem 'test_after_commit'
  gem 'rspec-sidekiq'
  gem 'database_rewinder', github: 'ntxcode/database_rewinder', branch: 'filtering_interface'
  gem 'shoulda-matchers'
  gem 'knapsack'
  gem 'rubocop'
  gem 'rspec-nc', github: 'estevaoam/rspec-nc'
  gem 'webmock'
end
