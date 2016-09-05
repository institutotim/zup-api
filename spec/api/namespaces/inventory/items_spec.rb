require 'app_helper'

describe 'Namespaces Inventories Items' do
  let(:user)      { create(:user) }
  let(:namespace) { create(:namespace) }

  let!(:inventory_one) { create(:inventory_item, namespace: user.namespace) }
  let!(:inventory_two) { create(:inventory_item, namespace: namespace) }

  describe 'GET /inventory/items' do
    it 'return only inventories of current namespace' do
      get '/inventory/items', nil, auth(user)

      expect(response.status).to be_a_success_request

      json = parsed_body['items']
      returned_ids = json.map { |j| j['id'] }

      expect(returned_ids).to include(inventory_one.id)
      expect(returned_ids).to_not include(inventory_two.id)
    end
  end

  describe 'GET /search/inventory/items' do
    it 'return only inventories of current namespace' do
      get '/search/inventory/items', nil, auth(user)

      expect(response.status).to be_a_success_request

      json = parsed_body['items']
      returned_ids = json.map { |j| j['id'] }

      expect(returned_ids).to include(inventory_one.id)
      expect(returned_ids).to_not include(inventory_two.id)
    end
  end
end
