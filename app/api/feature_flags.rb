module FeatureFlags
  class API < Base::API
    resources :feature_flags do
      desc 'List all feature flags'
      get do
        feature_flags = FeatureFlag.all
        { flags: FeatureFlag::Entity.represent(feature_flags) }
      end

      desc 'Update a feature flag'
      params do
        optional :status, type: Integer, desc: '0 to disable, 1 to enable'
      end
      put ':id' do
        authenticate!
        validate_permission!(:manage, FeatureFlag)

        feature_flag = FeatureFlag.find(params[:id])

        flag_params = safe_params.permit(:status)

        if feature_flag.update(flag_params)
          { message: 'Flag updated successfully' }
        else
          { message: 'Error updating flag' }
        end
      end
    end
  end
end
