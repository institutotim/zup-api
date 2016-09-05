require 'app_helper'

describe 'Namespaces Chat Rooms' do
  let(:namespace_one) { create(:namespace) }
  let(:namespace_two) { create(:namespace) }

  let(:user)  { create(:user) }

  context 'collections' do
    let!(:chat_one) { create(:chat_room, namespace: namespace_one) }
    let!(:chat_two) { create(:chat_room, namespace: namespace_two) }

    describe 'GET /chat_rooms' do
      it 'filter chat rooms by namespaces of user' do
        get '/chat_rooms', nil, auth(user, namespace_one.id)

        expect(response.status).to be_a_success_request

        json = parsed_body['chat_rooms']

        expect(json.size).to eq(1)

        returned_ids = json.map { |g| g['id'] }

        expect(returned_ids).to include(chat_one.id)
        expect(returned_ids).to_not include(chat_two.id)
      end
    end
  end
end
