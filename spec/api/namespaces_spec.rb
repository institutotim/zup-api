require 'app_helper'

describe Namespaces::API do
  let(:user)      { create(:user) }
  let(:namespace) { create(:namespace) }

  describe 'GET /namespaces' do
    let!(:namespaces) { create_list(:namespace, 3) }

    it 'return all namespaces' do
      get '/namespaces', nil, auth(user)

      expect(response.status).to be_a_success_request

      json = parsed_body['namespaces']

      expect(json.size).to eq(4)

      expected_ids = namespaces.map(&:id).push(user.namespace_id)

      expect(json.map { |r| r['id'] }).to match_array(expected_ids)
    end
  end

  describe 'POST /namespaces' do
    it 'create a new namespace' do
      post '/namespaces', { name: 'Namespace' }, auth(user)

      expect(response.status).to be_a_requisition_created

      json = parsed_body['namespace']

      expect(json['id']).to_not be_nil
      expect(json['name']).to eq('Namespace')
    end
  end

  describe 'GET /namespaces/:id' do
    it 'return namespace info' do
      get "/namespaces/#{namespace.id}", nil, auth(user)

      expect(response.status).to be_a_success_request

      json = parsed_body['namespace']

      expect(json['id']).to eq(namespace.id)
      expect(json['name']).to eq(namespace.name)
    end
  end

  describe 'PUT /namespaces/:id' do
    it 'update the namespace' do
      put "/namespaces/#{namespace.id}", { name: 'Edited Namespace' }, auth(user)

      expect(response.status).to be_a_success_request

      json = parsed_body['namespace']

      expect(json['id']).to eq(namespace.id)
      expect(json['name']).to eq('Edited Namespace')
    end
  end

  describe 'DELETE /namespaces/:id' do
    it 'removes an existent namespace' do
      delete "/namespaces/#{namespace.id}", nil, auth(user)

      expect(response.status).to be_a_no_content_request
      expect(Namespace.find_by(id: namespace.id)).to be_nil
    end
  end
end
