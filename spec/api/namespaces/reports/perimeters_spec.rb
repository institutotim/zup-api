require 'app_helper'

describe 'Namespaces Perimeters' do
  let(:user) { create(:user) }

  describe 'GET /reports/permiters' do
    let(:namespace)      { create(:namespace) }
    let!(:perimeter_one) { create(:reports_perimeter, namespace: user.namespace) }
    let!(:perimeter_two) { create(:reports_perimeter, namespace: namespace) }

    it 'return only perimeter of current namespace' do
      get '/reports/perimeters', nil, auth(user)

      expect(response.status).to be_a_success_request

      json = parsed_body['perimeters']
      returned_ids = json.map { |j| j['id'] }

      expect(returned_ids).to include(perimeter_one.id)
      expect(returned_ids).to_not include(perimeter_two.id)
    end
  end
end
