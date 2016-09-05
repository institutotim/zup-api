module Settings
  class API < Base::API
    namespace :settings do
      desc 'Return all the app settings'
      get do
        settings = Setting.all

        {
          settings: Setting::Entity.represent(settings)
        }
      end

      desc 'Create a new settings'
      params do
        optional :value, desc: 'Could be an array, JSON, string, or array of JSON'
      end
      put ':name' do
        setting = Setting.find_by!(name: params[:name])
        setting.update(value: params[:value])

        {
          setting: Setting::Entity.represent(setting)
        }
      end
    end
  end
end
