require 'spec_helper'

describe Users::API do
  describe 'POST /authenticate' do
    let(:user) { create(:user, password: '123456') }
    let(:valid_params) do
      Oj.load <<-JSON
        {
          "email": "#{user.email}",
          "password": "123456"
        }
      JSON
    end

    it 'returns the user and the access key if successful' do
      post '/authenticate', valid_params

      response.status.should == 201
      parsed_body['token'].should == user.last_access_key
    end

    it 'returns error message' do
      valid_params[:password] = 'wrongpassword'
      post '/authenticate', valid_params
      response.status.should == 401
      parsed_body.should include('error')
    end

    context 'passing device token and type' do
      let(:device_token) { SecureRandom.hex }
      let(:device_type) { 'ios' }

      before do
        valid_params['device_token'] = device_token
        valid_params['device_type'] = device_type
      end

      it 'updates the user' do
        post '/authenticate', valid_params
        expect(response.status).to eq(201)
        user.reload
        expect(user.device_token).to eq(device_token)
        expect(user.device_type).to eq(device_type)
      end
    end
  end

  describe 'DELETE /sign_out' do
    let(:user) { create(:user) }
    let(:access_key) { user.access_keys.last }

    it 'expires the access key' do
      delete '/sign_out', token: access_key.key
      expect(response.status).to eq(200)

      access_key.reload
      expect(access_key).to be_expired
      expect(access_key.expired).to_not be_blank
    end
  end

  describe 'PUT /recover_password' do
    let(:user) { create(:user) }
    let(:valid_params) do
      Oj.load <<-JSON
        {
          "email": "#{user.email}"
        }
      JSON
    end

    it 'sends a reset password e-mail' do
      expect(user.reset_password_token).to be_blank
      put '/recover_password', valid_params
      expect(response.status).to eq(200)
      expect(user.reload.reset_password_token).to_not be_blank
    end
  end

  describe 'PUT /reset_password' do
    let(:user) { create(:user) }
    let(:valid_params) do
      {
        token: user.reset_password_token,
        new_password: 'otherpassword',
        new_password_confirmation: 'otherpassword'
      }
    end
    let(:invalid_params) do
      {
        token: user.reset_password_token,
        new_password: 'otherpassword',
        new_password_confirmation: 'differentpassword'
      }
    end

    it 'resets the user password' do
      User.request_password_recovery(user.email)
      user.reload

      put '/reset_password', valid_params
      expect(response.status).to eq(200)

      user.reload
      expect(user.check_password('otherpassword')).to be(true)
    end

    it 'raise validation error when user password do not match with confirmation' do
      User.request_password_recovery(user.email)
      user.reload

      put '/reset_password', invalid_params
      expect(response.status).to eq(400)
    end
  end

  describe 'POST /users' do
    let!(:guest_group) { create(:guest_group) }
    let!(:namespace)   { create(:namespace) }

    let(:valid_params) do
      Oj.load <<-JSON
        {
          "email": "johnk12@gmail.com",
          "password": "astrongpassword",
          "password_confirmation": "astrongpassword",
          "name": "John Mayer",
          "phone": "11941892958",
          "commercial_phone": "11941892958",
          "skype": "john.mayer",
          "document": "11111111111",
          "address": "Rua Abilio Soares, 140",
          "postal_code": "04005000",
          "district": "Paraiso",
          "city": "São Paulo",
          "facebook_user_id": 12345678,
          "device_token": "#{SecureRandom.hex}",
          "device_type": "ios",
          "namespace_id": "#{namespace.id}"
        }
      JSON
    end

    it 'creates a user if every required param is ok' do
      post '/users', valid_params
      expect(response.status).to eq(201)

      last_user = User.last
      expect(last_user.email).to eq('johnk12@gmail.com')

      body = parsed_body
      expect(body).to include('message')
      expect(body).to include('user')
      expect(body['user']['email']).to eq('johnk12@gmail.com')
      expect(body['user']['encrypted_password']).to be_nil
      expect(body['user']['updated_at']).to be_blank
      expect(body['user']['facebook_user_id']).to eq(12345678)
      expect(body['user']['device_token']).to_not be_blank
      expect(body['user']['device_type']).to_not be_blank
      expect(last_user.groups).to include(guest_group)
    end

    it 'returns error message if a required param is missing' do
      valid_params.delete('email')
      post '/users', valid_params
      expect(response.status).to eq(400)
      body = parsed_body

      expect(body).to include('error')
      expect(body['error']).to include('email')
      expect(body['error']['email']).to include('não pode ficar em branco')
    end

    context 'setting the groups' do
      let(:groups) { create_list(:group, 3) }

      it 'sets the group' do
        valid_params['groups_ids'] = groups.map(&:id)

        post '/users', valid_params
        expect(response.status).to eq(201)
        last_user = User.last

        expect(last_user.groups).to eq(groups)
      end
    end

    context 'API generating the password' do
      before do
        valid_params.delete('password')
        valid_params.delete('password_confirmation')
        valid_params['generate_password'] = true
      end

      it "doesn't throw error for missing password fields" do
        post '/users', valid_params
        expect(response.status).to eq(201)
        last_user = User.last

        expect(last_user.encrypted_password).to_not be_blank
      end
    end
  end

  describe 'GET /users/:id' do
    let(:user) { create(:user) }

    it "returns user's data" do
      get "/users/#{user.id}", nil, auth(nil, user.namespace_id)
      expect(response.status).to eq(200)

      body = parsed_body
      expect(body).to include('user')

      expect(body['user']['id']).to eq(user.id)
      expect(body['user']['email']).to eq(user.email)
      expect(body['user']['encrypted_password']).to be_nil
      expect(body['user']['updated_at']).to be_blank
    end

    it "returns error message if id doesn't exists" do
      get '/users/1231231', nil, auth(nil, user.namespace_id)
      expect(response.status).to eq(404)
      body = parsed_body
      expect(body).to include('error')
      expect(body['error']).to match(/Couldn't find/)
    end
  end

  describe 'GET /me' do
    let(:user) { create(:user) }
    it "returns the signed user's data" do
      get '/me', nil, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body

      expect(body).to include('user')
      expect(body['user']['id']).to eq(user.id)
      expect(body['user']['encrypted_password']).to be_nil
      expect(body['user']['updated_at']).to be_blank
    end

    it 'accepts the token on header' do
      get '/me', nil, auth(user)
      expect(response.status).to eq(200)
    end
  end

  describe 'DELETE /me' do
    let(:user) { create(:user) }

    it 'destroys current user' do
      delete '/me', nil, auth(user)
      expect(user.reload).to be_disabled
    end
  end

  describe 'PUT /users' do
    let!(:user) { create(:user, name: 'Carlos Morais', email: 'email@gmail.com', postal_code: '22130-011') }
    let!(:new_group) { create(:group) }

    def do_action
      put "/users/#{user.id}", valid_params, auth(user)
    end

    context 'success' do
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "email": "anotheremail@gmail.com",
            "name": "Lucas",
            "postal_code": "20230-001",
            "groups_ids": [#{new_group.id}]
          }
        JSON
      end

      it 'returns 200 status' do
        do_action
        expect(response.status).to eq(200)
      end

      it "updates user's info" do
        do_action
        user.reload
        expect(user.email).to eq('anotheremail@gmail.com')
        expect(user.name).to eq('Lucas')
        expect(user.postal_code).to eq('20230-001')
      end

      it "updates user's groups as well" do
        do_action
        expect(user.reload.groups).to include(new_group)
      end
    end

    describe 'changing password' do
      let!(:user) { create(:guest_user, password: '123456') }

      let(:valid_params) do
        Oj.load <<-JSON
          {
            "password": "12345678",
            "password_confirmation": "12345678"
          }
        JSON
      end

      context "current_password attribute isn't present" do
        it 'throws error' do
          do_action
          expect(response.status).to eq(400)
        end
      end

      context 'current_password attribute is present' do
        before do
          valid_params['current_password'] = '123456'
        end

        it "doesn't throw error" do
          do_action
          expect(response.status).to eq(200)
        end

        it 'updates the password' do
          expect do
            do_action
          end.to change{ user.reload.encrypted_password }
        end
      end

      context 'user manager changing the password' do
        let!(:admin_permission) { create(:admin_permissions) }
        let!(:admin_group) { create(:group, permission: admin_permission) }
        let!(:manager) { create(:user, groups: [admin_group]) }

        it "doesn't need current_password if a manager is changing" do
          put "/users/#{user.id}", valid_params, auth(manager)
          expect(response.status).to eq(200)
        end
      end
    end

    context 'invalid params' do
      let(:invalid_params) do
        Oj.load <<-JSON
          {
            "email": "a",
            "groups_ids": [#{new_group.id}]
          }
        JSON
      end

      def do_action
        put "/users/#{user.id}", invalid_params, auth(user)
      end

      it 'wont update users attributes' do
        expect do
          do_action
        end.to_not change{ user.reload.email }
      end

      it 'wont update the groups' do
        expect do
          do_action
        end.to_not change{ user.reload.groups }
      end
    end
  end

  describe 'DELETE /users/:id' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    it "destroys user's account" do
      delete "/users/#{user.id}", nil, auth(user)
      expect(response.status).to eq(200)
      expect(User.find_by(id: user.id)).to be_disabled
    end

    it "can't destroy user account if it doesn't have permission to" do
      group = create(:group)
      user.groups = [group]
      user.save!

      delete "/users/#{other_user.id}", nil, auth(user)
      expect(response.status).to eq(403)
    end
  end

  describe 'PUT /users/:id/enable' do
    let(:user) { create(:user, :disabled) }
    let(:other_user) { create(:user, :disabled) }

    it "enables user's account again" do
      put "/users/#{user.id}/enable", nil, auth(user)
      expect(response.status).to eq(200)
      expect(User.find_by(id: user.id)).to be_enabled
    end

    it "can't enable user account if it doesn't have permission to" do
      group = create(:group)
      user.groups = [group]
      user.save!

      put "/users/#{other_user.id}/enable", nil, auth(user)
      expect(response.status).to eq(403)
      expect(User.find_by(id: other_user.id)).to be_disabled
    end
  end

  describe 'GET /users' do
    let!(:user) { create(:user, name: 'Burns', email: 'burns@test.com') }
    let!(:users) { create_list(:user, 5) }
    let!(:group) { create(:group) }
    let(:valid_params) do
      Oj.load <<-JSON
        {
          "name": "burns",
          "email": "burns",
          "groups": "#{group.id}"
        }
      JSON
    end

    it 'returns all users if no filter is selected' do
      get '/users', nil, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body

      expect(body).to include('users')
      expect(body['users'].size).to eq(6)
      expect(body['users'].first['id']).to_not be_nil
    end

    it 'returns the user that satisfy the filter' do
      valid_params.delete('groups')

      get '/users', valid_params, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body

      expect(body).to include('users')
      expect(body['users'].first['id']).to eq(user.id)
    end

    it 'retuns the user that is on the group' do
      valid_params.delete('name')
      valid_params.delete('email')

      group.users << user
      group.save

      get '/users', valid_params, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body

      expect(body).to include('users')
      expect(body['users'].first['id']).to eq(user.id)
      expect(body['users'].size).to eq(1)
    end

    context 'disabled: true' do
      let!(:disabled_user) { create(:user, :disabled) }
      it 'returns disabled users' do
        get '/users?disabled=true', nil, auth(user)
        body = parsed_body

        expect(body['users'].map do |u|
          u['id']
        end).to include(disabled_user.id)
      end
    end
  end

  describe 'GET /users/unsubscribe/:token' do
    let(:url) { "/users/unsubscribe/#{token}" }

    subject { get url }

    context 'with valid token' do
      let(:user) { create(:user) }
      let(:token) { user.unsubscribe_email_token }

      it 'unsubscribes user' do
        subject
        expect(user.reload.email_notifications).to be_falsy
      end
    end

    context 'with non-existent token' do
      let(:token) { SecureRandom.hex }

      it 'returns error message' do
        subject
        body = parsed_body

        expect(body['message']).to eq('Usuário não encontrado')
      end
    end
  end

  describe 'GET /autocomplete/user' do
    let!(:logged_user) { create(:user, name: 'Trunks') }
    let!(:son_goku) { create(:user, name:'Son Goku') }
    let!(:son_gohan) { create(:user, name:'Son Gohan') }

    def make_request
      get '/autocomplete/user?term=son', nil, auth(logged_user)
    end

    subject(:body) do
      make_request
      parsed_body
    end

    it 'returns success code' do
      make_request
      expect(response.status).to eq(200)
    end

    it 'returns the correct users' do
      returned_ids = body['result'].map { |h| h['id'] }

      expect(returned_ids).to include(son_gohan.id)
      expect(returned_ids).to include(son_goku.id)
    end

    it "returns correct user's params" do
      user_hash = body['result'].first

      expect(user_hash['id']).to eq(son_gohan.id)
      expect(user_hash['name']).to eq(son_gohan.name)
      expect(user_hash['mention_string']).to eq("@U#{son_gohan.id}")
    end

    it 'orders the users by name asc' do
      expect(body['result'].first['id']).to eq(son_gohan.id)
    end

    it 'returns only 5 users' do
      create_list(:user, 4, name: 'Son Goten')
      expect(body['result'].size).to eq(5)
    end
  end
end
