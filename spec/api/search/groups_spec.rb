require 'spec_helper'

describe Search::Groups::API do
  let(:user) { create(:user) }

  context 'GET /search/groups' do
    let(:groups) { create_list(:group, 5, namespace: user.namespace) }

    context 'by name' do
      it 'returns the correct groups' do
        group = groups.sample
        group.update(name: 'Nome de teste')

        get '/search/groups?name=teste', nil, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body['groups']).to_not be_empty
        expect(body['groups'].first['id']).to eq(group.id)
      end
    end
  end
end
