require 'spec_helper'

describe FeatureFlags::API do
  let(:user) { create(:user) }

  describe 'GET /feature_flags' do
    let!(:feature_flags) { create_list(:feature_flag, 3) }

    it 'returns all flags' do
      get '/feature_flags'
      expect(response.status).to be_a_success_request
      body = parsed_body

      expect(body['flags'].size).to eq(3)
    end
  end

  describe 'PUT /feature_flags/:id' do
    let(:feature_flag) { create(:feature_flag, :disabled) }
    let(:valid_params) do
      Oj.load <<-JSON
        {
          "status": 1
        }
      JSON
    end

    it 'updates the feature flag' do
      put "/feature_flags/#{feature_flag.id}", valid_params, auth(user)
      expect(response.status).to be_a_success_request

      feature_flag.reload
      expect(feature_flag).to be_enabled
    end
  end
end
