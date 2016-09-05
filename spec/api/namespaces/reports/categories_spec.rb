require 'app_helper'

describe 'Namespaces Reports Categories' do
  let(:user) { create(:user) }

  describe 'GET /reports/categories' do
    let(:namespace)     { create(:namespace) }
    let!(:category_one) { create(:reports_category, namespace: user.namespace) }
    let!(:category_two) { create(:reports_category, namespace: namespace) }

    it 'return only categories of current namespace' do
      get '/reports/categories', nil, auth(user)

      expect(response.status).to be_a_success_request

      json = parsed_body['categories']
      returned_ids = json.map { |j| j['id'] }

      expect(returned_ids).to include(category_one.id)
      expect(returned_ids).to_not include(category_two.id)
    end
  end

  describe 'POST /reports/categories' do
    let(:namespace) { create(:namespace) }

    let(:valid_params) do
      {
        title: 'A very cool report category',
        icon: Base64.encode64(fixture_file_upload("#{Application.config.root}/spec/fixtures/images/valid_report_category_icon.png").read),
        marker: Base64.encode64(fixture_file_upload("#{Application.config.root}/spec/fixtures/images/valid_report_category_marker.png").read),
        resolution_time: 2 * 60 * 60 * 24,
        user_response_time: 1 * 60 * 60 * 24,
        color: '#f3f3f3',
        priority: 'high',
        confidential: true,
        statuses: {
          0 =>  { title: 'Open', color: '#ff0000', initial: true, final: false, active: true, private: false },
          1 =>  { title: 'Closed', color: '#f4f4f4', final: true, initial: false, active: false, private: false }
        }
      }
    end

    it 'create a new category in current namespace' do
      post '/reports/categories', valid_params, auth(user, namespace.id)

      expect(response.status).to eq(201)
      expect(parsed_body['category']['namespace']['id']).to eq(namespace.id)
    end

    it 'create a global category' do
      valid_params[:global] = true

      post '/reports/categories', valid_params, auth(user, namespace.id)

      expect(response.status).to eq(201)
      expect(parsed_body['category']['namespace']).to be_nil
    end
  end
end
