require 'app_helper'

describe 'Namespaces Reports Items' do
  let(:user) { create(:user) }

  describe 'GET /reports/items' do
    let(:namespace)   { create(:namespace) }
    let!(:report_one) { create(:reports_item, namespace: user.namespace) }
    let!(:report_two) { create(:reports_item, namespace: namespace, status: create(:status)) }

    it 'return only reports of current namespace' do
      get '/reports/items', nil, auth(user)

      expect(response.status).to be_a_success_request

      json = parsed_body['reports']
      returned_ids = json.map { |j| j['id'] }

      expect(returned_ids).to include(report_one.id)
      expect(returned_ids).to_not include(report_two.id)
    end
  end
end
