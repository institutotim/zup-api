require 'spec_helper'

describe ChatRooms::API do
  describe 'GET /chat_rooms' do
    let!(:chat_manager_permission) { create(:group_permission, manage_chat_rooms: true) }
    let!(:chat_rooms_group) { create(:group, permission: chat_manager_permission) }
    let!(:old_chat_room) { create(:chat_room, title: 'Old Room', created_at: 2.hours.ago) }
    let!(:new_chat_room) { create(:chat_room, title: 'New Room', created_at: 1.hour.ago) }
    let!(:logged_user) { create(:user, groups: [chat_rooms_group]) }

    subject(:make_request) { get '/chat_rooms', nil, auth(logged_user) }

    context 'user has manager permission' do
      it 'returns 200 success' do
        make_request
        expect(response.status).to eq(200)
      end

      it 'returns chat_rooms ordered by created_at desc' do
        make_request
        body = parsed_body
        expect(body['chat_rooms'][0]['id']).to eq(new_chat_room.id)
      end

      it "returns chat_rooms's data correctly" do
        make_request
        body = parsed_body

        expect(body['chat_rooms'][0]['id']).to eq(new_chat_room.id)
        expect(body['chat_rooms'][0]['title']).to eq(new_chat_room.title)
      end

      context 'default pagination' do
        before do
          create_list(:chat_room, 26)
        end

        it 'returns only 25 chat_rooms by default' do
          make_request
          body = parsed_body
          expect(body['chat_rooms'].size).to eq(25)
        end
      end

      context 'defining pagination limit' do
        before do
          create_list(:chat_room, 3)
        end

        it 'returns only 2 chat_rooms' do
          get '/chat_rooms', { per_page: 2 }, auth(logged_user)
          body = parsed_body
          expect(body['chat_rooms'].size).to eq(2)
        end
      end

      context 'with query search' do
        before do
          get '/chat_rooms', { query: 'New Room' }, auth(logged_user)
        end

        it { expect(parsed_body['chat_rooms']).to include_an_entity_of(new_chat_room) }
        it { expect(parsed_body['chat_rooms']).to_not include_an_entity_of(old_chat_room) }
        it { expect(parsed_body['chat_rooms'].count).to eq(1) }
      end
    end

    context 'user can only access some chat_rooms' do
      let!(:some_chat_permission) { create(:group_permission, chat_rooms_read: [new_chat_room.id]) }
      let!(:only_one_chat_room_group) { create(:group, permission: some_chat_permission) }

      before do
        logged_user.groups = [only_one_chat_room_group]
        logged_user.save!
      end

      it 'return only the chat_rooms that the user can access' do
        make_request
        body = parsed_body
        expect(body['chat_rooms'][0]['id']).to eq(new_chat_room.id)
        expect(body['chat_rooms'][1]).to be_nil
      end
    end
  end

  describe 'POST /chat_rooms' do
    subject(:make_request) { post '/chat_rooms', params, auth(logged_user) }

    context 'user has permission' do
      let!(:chat_manager_permission) { create(:group_permission, manage_chat_rooms: true) }
      let!(:chat_rooms_group) { create(:group, permission: chat_manager_permission) }
      let!(:logged_user) { create(:user, groups: [chat_rooms_group]) }

      context 'with required fields filled' do
        let(:params) do
          { title: 'Casos sérios' }
        end

        it 'responds with 201 status code' do
          make_request
          expect(response.status).to eq(201)
        end

        it 'creates a new ChatRoom' do
          expect do
            make_request
          end.to change{ ChatRoom.count }.by(1)
        end

        it 'creates the ChatRoom with correct values' do
          make_request
          chat_room = ChatRoom.last

          expect(chat_room.title).to eq('Casos sérios')
        end

        it "returns chat_rooms's data correctly" do
          make_request
          body = parsed_body
          chat_room = ChatRoom.last

          expect(body['message']).to eq('Sala de chat criada com sucesso')
          expect(body['chat_room']['id']).to eq(chat_room.id)
          expect(body['chat_room']['title']).to eq('Casos sérios')
        end
      end

      context 'missing chat_room title' do
        let(:params) do
          { title: '' }
        end

        it 'returns 400 error code' do
          make_request
          expect(response.status).to eq(400)
        end
      end
    end

    context 'user doesnt have manager permission' do
      let!(:common_permission) { create(:group_permission, manage_chat_rooms: false) }
      let!(:group) { create(:group, permission: common_permission) }
      let!(:logged_user) { create(:user, groups: [group]) }

      let(:params) do
        { title: 'Casos sérios' }
      end

      it 'doesnt create the chat_room' do
        expect do
          make_request
        end.to_not change{ ChatRoom.count }
      end

      it 'returns a 403 error code' do
        make_request
        expect(response.status).to eq(403)
      end
    end
  end

  describe 'GET /chat_rooms/:id' do
    let!(:chat_room) { create(:chat_room, title: 'Título') }
    subject(:make_request) { get "/chat_rooms/#{chat_room.id}", {}, auth(logged_user) }

    context 'user has permission' do
      let!(:chat_manager_permission) { create(:group_permission, manage_chat_rooms: true) }
      let!(:chat_rooms_group) { create(:group, permission: chat_manager_permission) }
      let!(:logged_user) { create(:user, groups: [chat_rooms_group]) }

      context "returns chat_rooms's data correctly" do
        before { make_request }

        it { expect(response.status).to be_a_success_request }
        it { expect(parsed_body['chat_room']).to be_an_entity_of(chat_room) }
      end

      context 'wrong chat_room ID' do
        before do
          get '/chat_rooms/1234567', {}, auth(logged_user)
        end

        it { expect(response.status).to be_a_not_found }
      end
    end

    context 'user doesnt have manager permission' do
      let!(:common_permission) { create(:group_permission, manage_chat_rooms: false) }
      let!(:group) { create(:group, permission: common_permission) }
      let!(:logged_user) { create(:user, groups: [group]) }

      before { make_request }

      it { expect(response.status).to be_a_forbidden }
    end
  end

  describe 'PUT /chat_rooms/:id' do
    let!(:chat_room) { create(:chat_room, title: 'Título') }
    subject(:make_request) { put "/chat_rooms/#{chat_room.id}", params, auth(logged_user) }

    context 'user has permission' do
      let!(:chat_manager_permission) { create(:group_permission, manage_chat_rooms: true) }
      let!(:chat_rooms_group) { create(:group, permission: chat_manager_permission) }
      let!(:logged_user) { create(:user, groups: [chat_rooms_group]) }

      context 'with required fields filled' do
        let(:params) do
          { title: 'Novo título' }
        end

        it 'responds with 200 status code' do
          make_request
          expect(response.status).to eq(200)
        end

        it 'updates ChatRoom title' do
          make_request
          expect(chat_room.reload.title).to eq('Novo título')
        end

        it "returns chat_rooms's data correctly" do
          make_request
          body = parsed_body
          chat_room = ChatRoom.last

          expect(body['message']).to eq('Sala de chat atualizada com sucesso')
          expect(body['chat_room']['id']).to eq(chat_room.id)
          expect(body['chat_room']['title']).to eq('Novo título')
        end
      end

      context 'missing chat_room title' do
        let(:params) do
          { title: '' }
        end

        it 'returns 400 error code' do
          make_request
          expect(response.status).to eq(400)
        end
      end

      context 'wrong chat_room ID' do
        let(:params) do
          { title: 'Novo título' }
        end

        it 'returns 404 error code' do
          put '/chat_rooms/1234567', params, auth(logged_user)
          expect(response.status).to eq(404)
        end
      end
    end

    context 'user doesnt have manager permission' do
      let!(:common_permission) { create(:group_permission, manage_chat_rooms: false) }
      let!(:group) { create(:group, permission: common_permission) }
      let!(:logged_user) { create(:user, groups: [group]) }

      let(:params) do
        { title: 'Novo título' }
      end

      it 'returns a 403 error code' do
        make_request
        expect(response.status).to eq(403)
      end
    end
  end

  describe 'DELETE /chat_rooms/:id' do
    let!(:chat_room) { create(:chat_room) }
    subject(:make_request) { delete "/chat_rooms/#{chat_room.id}", nil, auth(logged_user) }

    context 'user has permission' do
      let!(:chat_manager_permission) { create(:group_permission, manage_chat_rooms: true) }
      let!(:chat_rooms_group) { create(:group, permission: chat_manager_permission) }
      let!(:logged_user) { create(:user, groups: [chat_rooms_group]) }

      it 'responds with 200 status code' do
        make_request
        expect(response.status).to eq(200)
      end

      it 'destroys the ChatRoom' do
        expect do
          make_request
        end.to change{ ChatRoom.count }.by(-1)
      end

      it 'returns a success message' do
        make_request
        body = parsed_body

        expect(body['message']).to eq('Sala de chat deletada com sucesso')
      end
    end

    context 'user doesnt have manager permission' do
      let!(:common_permission) { create(:group_permission, manage_chat_rooms: false) }
      let!(:group) { create(:group, permission: common_permission) }
      let!(:logged_user) { create(:user, groups: [group]) }

      it 'doesnt delete the chat_room' do
        expect do
          make_request
        end.to_not change{ ChatRoom.count }
      end

      it 'returns a 403 error code' do
        make_request
        expect(response.status).to eq(403)
      end
    end
  end
end
