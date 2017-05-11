require 'app_helper'

describe EventLogs::API do
  let(:user) { create(:user) }

  describe 'GET /event_logs' do
    let!(:event_logs) { create_list(:event_log, 3) }

    it 'return all event logs' do
      get '/event_logs', nil, auth(user)

      expect(response.status).to eq(200)

      body = parsed_body['event_logs']

      returned_ids = body.map { |b| b['id'] }
      expected_ids = event_logs.map { |ev| ev.id }

      expect(returned_ids).to match_array(expected_ids)
    end
  end

  describe 'middleware' do
    let(:group) { create(:group) }

    it 'create a new event log in a POST request' do
      expect(EventLog).to receive(:create).with(
        user: user,
        namespace: user.namespace,
        url: '/groups',
        headers: { 'Host' => 'example.org', 'Cookie' => '' },
        request_body: { name: 'Group' },
        request_method: 'POST'
      )

      post '/groups', { name: 'Group' }, auth(user)
    end

    it 'create a new event log in a PUT request' do
      expect(EventLog).to receive(:create).with(
        user: user,
        namespace: user.namespace,
        url: "/groups/#{group.id}",
        headers: { 'Host' => 'example.org', 'Cookie' => '' },
        request_body: { name: 'Group', id: group.id.to_s },
        request_method: 'PUT'
      )

      put "/groups/#{group.id}", { name: 'Group' }, auth(user)
    end

    it 'create a new event log in a DELETE request' do
      expect(EventLog).to receive(:create).with(
        user: user,
        namespace: user.namespace,
        url: "/groups/#{group.id}",
        headers: { 'Host' => 'example.org', 'Cookie' => '' },
        request_body: { name: 'Group', id: group.id.to_s },
        request_method: 'DELETE'
      )

      delete "/groups/#{group.id}", { name: 'Group' }, auth(user)
    end

    it 'do not create a new event log in a GET request' do
      expect(EventLog).to_not receive(:create)

      get '/groups', nil, auth(user)
    end
  end
end
