ENV['RACK_ENV'] = 'test'
ENV['DISABLE_MEMORY_CACHE'] = 'true'
ENV['DISABLE_EMAIL_SENDING'] = 'true'
require File.expand_path('../../application', __FILE__)

require 'knapsack'
Knapsack::Adapters::RspecAdapter.bind

require 'rspec/autorun'
require 'ffaker'
require 'cpf_faker'
require 'factory_girl'
require 'rack/test'
require 'webmock/rspec'

FactoryGirl.find_definitions

ActiveSupport::Deprecation.silenced = true

CarrierWave::Uploader::Base.enable_processing = false

WebMock.disable_net_connect!(allow_localhost: true)

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[("#{Application.config.root}/spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.include AliasesHelper
  config.include AuthenticationHelper
  config.include FactoryGirl::Syntax::Methods
  config.include IntegrationHelper
  config.include ImageHelper
  config.include RackTestExampleGroup
  config.include FileEncodingHelper

  config.before(:suite) do
    DatabaseRewinder.filter_options = { except: %w(spatial_ref_sys) }
    DatabaseRewinder.clean_all
  end

  config.filter_run_excluding broken: true
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.before(:each) do
    # Always create the guest group
    FactoryGirl.create(:guest_group)
    UserAbility.clear_cache
    Sidekiq::Worker.clear_all
    Thread.current[:current_namespace] = nil
  end

  config.after(:each) do
    DatabaseRewinder.clean
  end

  config.after(:all) do
    FileUtils.rm_rf(Dir["#{Application.config.root}/public/uploads/test"])
  end

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end
