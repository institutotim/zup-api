require 'app_helper'

describe 'Namespaces Users' do
  let(:namespace_one) { create(:namespace) }
  let(:namespace_two) { create(:namespace) }

  let(:permissions)   do
    create(
      :admin_permissions,
      manage_namespaces: false,
      namespaces_access: [namespace_one.id]
    )
  end

  let(:group) { create(:group, permission: permissions) }
  let(:user)  { create(:user, groups: [group], namespace: namespace_one) }

  let(:user_params) do
    {
      email: 'user@mail.com',
      name: 'User',
      phone: '(55) 5555-5555',
      document: '90346772737',
      address: 'Adress',
      postal_code: '123456-000',
      district: 'District',
      city: 'City',
      namespace_id: 9_999
    }
  end

  context 'collections' do
    let!(:user_one) { create(:user, namespace: namespace_one) }
    let!(:user_two) { create(:user, namespace: namespace_two) }

    describe 'GET /users' do
      it 'filter users by namespaces of user' do
        get '/users', nil, auth(user, namespace_one.id)

        expect(response.status).to be_a_success_request

        json = parsed_body['users']

        expect(json.size).to eq(2)

        returned_ids = json.map { |g| g['id'] }

        expect(returned_ids).to include(user_one.id)
        expect(returned_ids).to include(user.id)
        expect(returned_ids).to_not include(user_two.id)
      end

      context 'filter namespaces' do
        let(:namespace)        { create(:namespace) }
        let(:global_namespace) { create(:namespace, default: true) }
        let!(:user)            { create(:user, namespace: namespace) }
        let!(:global_user)     { create(:user, namespace: global_namespace) }

        it 'return only users from current namespace' do
          get '/users', nil, auth(user, namespace.id)

          expect(response.status).to be_a_success_request

          json = parsed_body['users']

          expect(json.size).to eq(1)

          returned_ids = json.map { |g| g['id'] }

          expect(returned_ids).to include(user.id)
          expect(returned_ids).to_not include(global_user.id)
        end

        it 'return only users from current namespace and global namespaces' do
          get '/users', { global_namespaces: true }, auth(user, namespace.id)

          expect(response.status).to be_a_success_request

          json = parsed_body['users']

          expect(json.size).to eq(2)

          returned_ids = json.map { |g| g['id'] }

          expect(returned_ids).to include(user.id)
          expect(returned_ids).to include(global_user.id)
        end
      end
    end

    describe 'GET /search/users' do
      it 'filter users by namespaces of user' do
        get '/search/users', nil, auth(user, namespace_one.id)

        expect(response.status).to be_a_success_request

        json = parsed_body['users']

        expect(json.size).to eq(2)

        returned_ids = json.map { |g| g['id'] }

        expect(returned_ids).to include(user_one.id)
        expect(returned_ids).to include(user.id)
        expect(returned_ids).to_not include(user_two.id)
      end
    end
  end
end
