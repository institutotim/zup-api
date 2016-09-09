require 'spec_helper'

describe ChatMessages::API do
  let!(:logged_user) { create(:user) }
  let!(:case_instance) { create(:case) }

  before do
    flow = case_instance.initial_flow
    flow.publish(logged_user)
    case_instance.update(flow_version: flow.versions.first.id)
  end

  describe 'GET /:chattable_type/:chattable_id/chat' do
    let!(:first_message) { create(:chat_message, :system_message, chattable: case_instance, created_at: 2.hours.ago) }
    let!(:second_message) { create(:chat_message, chattable: case_instance, created_at: 1.hour.ago) }

    subject(:make_request) { get "/case/#{case_instance.id}/chat", nil, auth(logged_user) }

    it 'returns 200 success' do
      make_request
      expect(response.status).to eq(200)
    end

    it 'returns messages ordered by created_at desc' do
      make_request
      body = parsed_body
      expect(body['messages'][0]['id']).to eq(second_message.id)
    end

    it "returns messages's data correctly" do
      make_request
      body = parsed_body

      expect(body['messages'][0]['id']).to eq(second_message.id)
      expect(body['messages'][0]['chattable_id']).to eq(case_instance.id)
      expect(body['messages'][0]['chattable_type']).to eq('case')
      expect(body['messages'][0]['kind']).to eq('user')
      expect(body['messages'][0]['text']).to eq(second_message.text)
      expect(body['messages'][0]['created_at']).to_not be_nil
      expect(body['messages'][0]['user']['id']).to eq(second_message.user.id)
    end

    context 'system message' do
      it 'doesnt return "user" field inside message' do
        make_request
        body = parsed_body

        expect(body['messages'][1]['user']).to be_nil
      end
    end

    context 'pagination' do
      before do
        create_list(:chat_message, 26, :system_message, chattable: case_instance)
      end

      it 'returns only 25 chat_messages by default' do
        make_request
        body = parsed_body
        expect(body['messages'].size).to eq(25)
      end
    end

    context 'defining pagination per_page' do
      before do
        create_list(:chat_message, 3, :system_message, chattable: case_instance)
      end

      it 'returns only 2 chat_messages' do
        get "/case/#{case_instance.id}/chat", { per_page: 2 }, auth(logged_user)
        body = parsed_body
        expect(body['messages'].size).to eq(2)
      end
    end
  end

  describe 'POST /chat/messages' do
    let!(:mentioned_user) { create(:user) }

    subject(:make_request) do
      Sidekiq::Testing.inline! do
        post '/chat/messages', params, auth(logged_user)
      end
    end

    context 'success' do
      let(:params) do
        {
          text: "Now do it again, @[#{mentioned_user.id}:#{mentioned_user.name}]",
          chattable_type: 'case',
          chattable_id: case_instance.id
        }
      end

      it 'responds with 201 status code' do
        make_request
        expect(response.status).to eq(201)
      end

      it 'creates a new ChatMessage' do
        expect do
          make_request
        end.to change{ ChatMessage.count }.by(1)
      end

      it 'creates the ChatMessage with correct values' do
        make_request
        chat_message = ChatMessage.last

        expect(chat_message.text).to eq(params[:text])
        expect(chat_message.chattable).to eq(case_instance)
        expect(chat_message.kind).to eq('user')
        expect(chat_message.user_id).to eq(logged_user.id)
      end

      it 'notify the mentioned users' do
        make_request

        chat_message = ChatMessage.last
        notifications = mentioned_user.notifications

        expect(notifications.count).to eq(1)
      end

      it "returns messages's data correctly" do
        make_request
        body = parsed_body
        chat_message = ChatMessage.last

        expect(body['chat_message']['id']).to eq(chat_message.id)
        expect(body['chat_message']['chattable_id']).to eq(case_instance.id)
        expect(body['chat_message']['chattable_type']).to eq('case')
        expect(body['chat_message']['kind']).to eq('user')
        expect(body['chat_message']['text']).to eq(chat_message.text)
        expect(body['chat_message']['created_at']).to_not be_nil
        expect(body['chat_message']['user']['id']).to eq(logged_user.id)
      end
    end

    context 'missing message text' do
      let(:params) do
        {
          chattable_type: 'Case',
          chattable_id: case_instance.id
        }
      end

      it 'returns 400 error code' do
        make_request
        expect(response.status).to eq(400)
      end
    end
  end
end
