require File.expand_path('../environment', __FILE__)

module ZupApi
end

require 'rack/session/cookie'
require 'sidekiq/web'

ZupServer = Rack::Builder.new do
  use Rack::Session::Cookie,
      secret: ENV['COOKIE_SECRET'] || '882022c1ac5465d2f9cb4906104abd2907afa2e5b003d47f63d2a1882653391d'

  use OmniAuth::Builder do
    provider :twitter, ENV['TWITTER_CONSUMER_KEY'], ENV['TWITTER_CONSUMER_SECRET'], x_auth_access_type: 'write'
    provider :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET']
    provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET']
  end

  map '/' do
    run ZUP::API
  end

  map '/sidekiq' do
    use Rack::Auth::Basic, 'Secret Area' do |username, password|
      username == SIDEKIQ_USER && password == SIDEKIQ_PASSWORD
    end

    run Sidekiq::Web
  end
end
