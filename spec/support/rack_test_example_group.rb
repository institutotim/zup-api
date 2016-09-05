module RackTestExampleGroup
  require 'rack/test'

  include Rack::Test::Methods

  def app
    ::ZupServer
  end

  def response
    last_response
  end

  def response_json
    JSON.parse(response.body, max_nesting: 19)
  end
end

RSpec.configure do |config|
  config.include RackTestExampleGroup, type: :rack, example_group: {
                                       file_path: %r{(spec/app/api)|(spec/app/assets/javascripts)}
                                     }
end
