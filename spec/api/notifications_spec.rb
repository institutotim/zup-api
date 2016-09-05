require 'spec_helper'

describe Notifications::API do
  let(:logged_user) { create(:user) }
  let(:chat_message) { create(:chat_message) }
  let!(:notifications) { create_list(:notification, 11, notificable: chat_message, user: logged_user) }

  describe 'GET /notifications' do
    subject(:get_notifications) { get '/notifications', nil, auth(logged_user) }

    context 'successfully' do
      before { get_notifications }

      it { expect(response.status).to be_a_success_request }

      it 'returns only 10 latest notifications' do
        expect(parsed_body['notifications'].count).to eq(10)
      end

      it 'returns notifications ordered by created_at desc' do
        expect(parsed_body['notifications'][0]['id']).to eq(notifications.last.id)
      end
    end
  end

  describe 'PUT /notifications/read-all' do
    let(:all_read) { Array.new(11, true) }
    subject(:read_all) { put '/notifications/read-all', nil, auth(logged_user) }

    context 'successfully' do
      before { read_all }

      it { expect(response.status).to be_a_success_request }
      it { expect(logged_user.notifications.reload.pluck(:read)).to eq(all_read) }
    end
  end

  describe 'DELETE /notifications/:id' do
    subject(:delete_notification) { delete "/notifications/#{notifications.first.id}", nil, auth(logged_user) }

    context 'successfully' do
      before { delete_notification }

      it { expect(response.status).to be_a_success_request }
      it 'removes notification' do
        expect(Notification.count).to eq(10)
      end
    end
  end
end
