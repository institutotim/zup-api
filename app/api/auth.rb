module Auth
  class API < Base::API
    namespace :auth do
      get 'twitter/callback' do
        unless env['omniauth.auth'].nil?
          user_info = env['omniauth.auth']

          {
            name: user_info.info.name,
            twitter_uid: user_info.uid
          }
        end
      end

      get 'facebook/callback' do
        unless env['omniauth.auth'].nil?
          user_info = env['omniauth.auth']

          {
            name: user_info.info.name,
            facebook_uid: user_info.uid,
            email: user_info.info.email
          }
        end
      end

      get 'google_oauth2/callback' do
        unless env['omniauth.auth'].nil?
          user_info = env['omniauth.auth']

          {
            name: user_info.info.name,
            google_uid: user_info.uid,
            email: user_info.info.email
          }
        end
      end
    end
  end
end
