require 'app_helper'

describe 'Namespaces Groups' do
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
  let(:user)  { create(:user, groups: [group]) }

  context 'collections' do
    let!(:group_one)   { create(:group, namespace: namespace_one) }
    let!(:group_two)   { create(:group, namespace: namespace_two) }
    let!(:group_three) { create(:group) }

    describe 'GET /groups' do
      it 'filter groups by namespaces of user' do
        get '/groups', nil, auth(user, namespace_one.id)

        expect(response.status).to be_a_success_request

        json = parsed_body['groups']

        expect(json.size).to eq(1)

        returned_ids = json.map { |g| g['id'] }

        expect(returned_ids).to include(group_one.id)
        expect(returned_ids).to_not include(group_two.id)
        expect(returned_ids).to_not include(group_three.id)
      end

      it 'return error when pass a invalid namespace' do
        get '/groups', nil, auth(user, 9_999)

        expect(response.status).to be_a_unprocessable_entity

        expect(parsed_body['error']).to eq(I18n.t(:invalid_namespace))
        expect(parsed_body['type']).to eq('invalid_namespace')
      end

      context 'filter namespaces' do
        let(:namespace)         { create(:namespace) }
        let(:global_namespace)  { create(:namespace, default: true) }
        let!(:user)             { create(:user, namespace: namespace) }
        let!(:group)            { create(:group, namespace: namespace) }
        let!(:global_group)     { create(:group, namespace: global_namespace) }

        it 'return only groups from current namespace' do
          get '/groups', nil, auth(user, namespace.id)

          expect(response.status).to be_a_success_request

          json = parsed_body['groups']

          expect(json.size).to eq(1)

          returned_ids = json.map { |g| g['id'] }

          expect(returned_ids).to include(group.id)
          expect(returned_ids).to_not include(global_group.id)
        end

        it 'return only groups from current namespace and global namespaces' do
          get '/groups', { global_namespaces: true }, auth(user, namespace.id)

          expect(response.status).to be_a_success_request

          json = parsed_body['groups']

          expect(json.size).to eq(2)

          returned_ids = json.map { |g| g['id'] }

          expect(returned_ids).to include(group.id)
          expect(returned_ids).to include(global_group.id)
        end
      end

      context 'user namespace' do
        let(:namespace)      { create(:namespace) }
        let(:user_namespace) { create(:namespace) }
        let(:user)           { create(:user, namespace: user_namespace) }
        let(:group_one)      { create(:group, namespace: namespace) }
        let(:group_two)      { create(:group, namespace: user_namespace) }

        it 'return only groups from namespace of current user' do
          get '/groups', { use_user_namespace: true }, auth(user, namespace.id)

          expect(response.status).to be_a_success_request

          json = parsed_body['groups']

          expect(json.size).to eq(1)

          returned_ids = json.map { |g| g['id'] }

          expect(returned_ids).to_not include(group_one.id)
          expect(returned_ids).to include(group_two.id)
        end
      end
    end

    describe 'GET /search/groups' do
      it 'filter groups by namespaces of user' do
        get '/search/groups', nil, auth(user, namespace_one.id)

        expect(response.status).to be_a_success_request

        json = parsed_body['groups']

        expect(json.size).to eq(1)

        returned_ids = json.map { |g| g['id'] }

        expect(returned_ids).to include(group_one.id)
        expect(returned_ids).to_not include(group_two.id)
        expect(returned_ids).to_not include(group_three.id)
      end
    end
  end

  describe 'POST /groups' do
    it 'return error when pass a invalid namespace' do
      post '/groups', { name: 'Group' }, auth(user, 9_999)

      expect(response.status).to be_a_unprocessable_entity

      expect(parsed_body['error']).to eq(I18n.t(:invalid_namespace))
      expect(parsed_body['type']).to eq('invalid_namespace')
    end
  end

  describe 'PUT /groups/:id' do
    it 'return error when pass a invalid namespace' do
      put "/groups/#{group.id}", nil, auth(user, 9_999)

      expect(response.status).to be_a_unprocessable_entity

      expect(parsed_body['error']).to eq(I18n.t(:invalid_namespace))
      expect(parsed_body['type']).to eq('invalid_namespace')
    end
  end
end
