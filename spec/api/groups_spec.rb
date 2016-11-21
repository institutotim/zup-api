require 'spec_helper'

describe Groups::API do
  let!(:user) { create(:user) }

  context 'POST /groups' do
    let(:valid_params) do
      Oj.load <<-JSON
        {
          "name": "Cool group",
          "permissions": {
            "inventories_full_access": true,
            "group_edit": [1, 2],
            "group_read_only": [99]
          },
          "users": ["#{user.id}"]
        }
      JSON
    end

    it 'needs authentication' do
      post '/groups', valid_params, auth(nil, user.namespace_id)
      expect(response.status).to eq(401)
    end

    it 'creates a group' do
      post '/groups', valid_params, auth(user)
      expect(response.status).to eq(201)
      body = parsed_body

      last_created_group = Group.last
      expect(last_created_group.name).to eq('Cool group')
      expect(last_created_group.permission.inventories_full_access).to eq(true)
      expect(last_created_group.permission.group_edit).to match_array([1, 2])
      expect(last_created_group.permission.group_read_only).to match_array([99])
      expect(last_created_group.users).to include(user)

      expect(body).to include('message')
      expect(body).to include('group')
      expect(body['group']['name']).to eq('Cool group')
      expect(body['group']['permissions']['group_edit']).to match_array([1, 2])
      expect(body['group']['permissions']['group_read_only']).to match_array([99])
    end

    it 'can create a group without users' do
      valid_params.delete('users')
      post '/groups', valid_params, auth(user)
      expect(response.status).to eq(201)
      body = parsed_body

      last_created_group = Group.last
      expect(last_created_group.name).to eq('Cool group')
      expect(last_created_group.users).to be_empty

      expect(body).to include('message')
      expect(body).to include('group')
      expect(body['group']['name']).to eq('Cool group')
      expect(body['group']['permissions']['group_edit']).to be_kind_of(Array)
    end

    it 'can create a group without permission' do
      valid_params.delete('permissions')
      post '/groups', valid_params, auth(user)
      expect(response.status).to eq(201)

      last_created_group = Group.last
      expect(last_created_group.permission).to be_present
    end
  end

  context 'GET /groups/:id' do
    let(:group) { create(:group) }

    it "returns group's data" do
      get "/groups/#{group.id}", nil, auth(nil, user.namespace_id)
      expect(response.status).to eq(200)
      body = parsed_body

      expect(body).to include('group')
      expect(body['group']['id']).to eq(group.id)
    end

    it "returns group's users if display_users is true" do
      get "/groups/#{group.id}?display_users=true", nil, auth(nil, user.namespace_id)
      expect(response.status).to eq(200)
      body = parsed_body

      expect(body).to include('group')
      expect(body['group']['id']).to eq(group.id)
      expect(body['group']['users']).to_not be_nil
    end

    it 'returns status 404 and error message if group is not found' do
      get '/groups/12313123', nil, auth(nil, user.namespace_id)
      expect(response.status).to eq(404)
      body = parsed_body
      expect(body).to include('error')
    end
  end

  context 'DELETE /groups/:id' do
    let(:user) { create(:user) }
    let(:group) { create(:group) }

    it 'delete the group' do
      delete "/groups/#{group.id}", nil, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body
      expect(body).to include('message')
      expect(Group.find_by(id: group.id)).to be_nil
    end
  end

  context 'PUT /groups/:id' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:group) { create(:group, users: [user]) }
    let(:valid_params) do
      Oj.load <<-JSON
        {
          "name": "An awesome name!",
          "users": [#{other_user.id}],
          "permissions": {
            "users_full_access": true
          }
        }
      JSON
    end

    it 'changes the group data' do
      put "/groups/#{group.id}", valid_params, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body
      expect(body).to include('message')

      changed_group = Group.find(group.id)
      expect(changed_group.name).to eq('An awesome name!')
      expect(changed_group.users).to include(other_user, user)
      expect(changed_group.users.count).to eq(2)
      expect(changed_group.permission.users_full_access).to be_truthy
    end
  end

  context 'POST /groups/:id/users' do
    let!(:user) { create(:user) }
    let(:group) { create(:group) }
    let(:valid_params) do
      Oj.load <<-JSON
        {
          "user_id": #{user.id}
        }
      JSON
    end

    it 'adds the user to the group' do
      post "/groups/#{group.id}/users", valid_params, auth(user)
      expect(response.status).to eq(201)
      expect(group.users).to include(user)
    end
  end

  context 'DELETE /groups/:id/users' do
    let!(:user) { create(:user) }
    let(:group) { create(:group) }
    let(:valid_params) do
      Oj.load <<-JSON
        {
          "user_id": #{user.id}
        }
      JSON
    end

    it 'adds the user to the group' do
      delete "/groups/#{group.id}/users", valid_params, auth(user)
      expect(response.status).to eq(200)
      expect(group.users).to_not include(user)
    end
  end

  context 'GET /groups' do
    let(:namespace) { create(:namespace) }
    let(:user) { create(:user, namespace: namespace) }
    let!(:member) { create(:user, name: 'Smithers') }
    let!(:group) { create(:group, name: 'Great group', namespace: namespace) }
    let!(:groups) { create_list(:group, 20, namespace: namespace) }

    let(:valid_params) do
      Oj.load <<-JSON
        {
          "name": "great"
        }
      JSON
    end

    it 'return all groups if no filter is given' do
      get '/groups', nil, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body

      expect(body).to include('groups')
      returned_ids = body['groups'].map { |g| g['id'] }
      expected_ids = groups.map { |g| g.id }.push(group.id)

      expect(returned_ids).to match_array(expected_ids)
    end

    it "return all groups with 'Great' on the name" do
      get '/groups', valid_params, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body

      expect(body).to include('groups')
      expect(body['groups'].first['id']).to eq(group.id)
    end

    it 'return all groups with the member name' do
      valid_params.delete('name')
      valid_params['user_name'] = member.name

      group.users << member
      group.save

      get '/groups', valid_params, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body

      expect(body).to include('groups')
      expect(body['groups'].last['id']).to eq(group.id)
    end

    context 'user can see only a few groups' do
      let(:groups_can_view) { groups.first(3) }
      let(:group) { create(:group, namespace: namespace) }

      before do
        group.permission.update(group_read_only: groups_can_view.map(&:id))
        user.groups = [group]
        user.save!
      end

      it 'only return those groups' do
        get '/groups', nil, auth(user)

        expect(response.status).to eq(200)
        body = parsed_body

        expect(body).to include('groups')
        expect(body['groups'].map do |g|
          g['id']
        end).to match_array(groups_can_view.map(&:id))
      end
    end

    context 'user can edit inventories categories permissions' do
      let(:groups_can_view) { groups }
      let(:group) { create(:group) }

      before do
        group.permission.update(inventories_categories_edit: [1])
        user.groups = [group]
        user.save!
      end

      it 'only return those groups' do
        get '/groups', nil, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body).to include('groups')
        expect(body['groups'].map do |g|
                 g['id']
               end).to match_array(groups_can_view.map(&:id))
      end
    end

    context 'user can edit reports categories permissions' do
      let(:groups_can_view) { groups }
      let(:group) { create(:group) }

      before do
        group.permission.update(reports_categories_edit: [1])
        user.groups = [group]
        user.save!
      end

      it 'only return those groups' do
        get '/groups', nil, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body).to include('groups')
        expect(body['groups'].map do |g|
                 g['id']
               end).to match_array(groups_can_view.map(&:id))
      end
    end
  end

  context 'GET /groups/:id/users' do
    let(:group) { create(:group) }
    let(:users) { create_list(:user, 5) }
    let(:wrong_users) { create_list(:user, 3) }

    it 'returns all group users' do
      group.user_ids = users.map(&:id)
      group.save

      get "/groups/#{group.id}/users", nil, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body

      users.each(&:reload)

      expect(body).to include('group')
      expect(body).to include('users')
      expect(body['users'].size).to eq(5)
      expect(body['users']).to match_array(
        Oj.load(User::Entity.represent(users, display_type: 'full').to_json)
      )
    end
  end

  context 'PUT /groups/:id/permissions' do
    let(:group) { create(:group) }

    context 'boolean permission' do
      let(:valid_params) do
        Oj.load <<-JSON
        {
          "users_full_access": true,
          "groups_full_access": true
        }
        JSON
      end

      it 'updates the group permission' do
        expect(group.permission.users_full_access).to eq(false)
        put "/groups/#{group.id}/permissions", valid_params, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body).to include('group')
        group.reload
        expect(group.permission.users_full_access).to eq(true)
        expect(body['group']['permissions']).to_not be_empty
      end
    end

    context 'array permission' do
      let(:valid_params) do
        Oj.load <<-JSON
        {
          "inventory_categories_can_view": [1,2,3,4],
          "inventory_categories_can_edit": [1,3,5,6]
        }
        JSON
      end

      it 'updates the group permission' do
        expect(group.permission.inventory_categories_can_view).to eq([])
        expect(group.permission.inventory_categories_can_edit).to eq([])

        put "/groups/#{group.id}/permissions", valid_params, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body).to include('group')
        group.reload
        expect(group.permission.inventory_categories_can_view).to eq([1, 2, 3, 4])
        expect(group.permission.inventory_categories_can_edit).to eq([1, 3, 5, 6])

        expect(body['group']['permissions']).to_not be_empty
      end
    end
  end

  context 'POST /groups/:id/clone' do
    let!(:group) { create(:group) }

    it 'should clone the group' do
      expect do
        post "/groups/#{group.id}/clone", {}, auth(user)
      end.to change(Group, :count).by(1)

      expect(parsed_body['group']['name']).to eq "Cópia de #{group.name}"
    end

    it 'should clone the group with permissions' do
      expect do
        post "/groups/#{group.id}/clone", {}, auth(user)
      end.to change(GroupPermission, :count).by(1)
    end
  end
end
