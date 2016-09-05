require 'app_helper'

describe Reports::Notifications do
  let(:user) { create(:user) }
  let(:item) { create(:reports_item) }
  let(:category) { item.category }

  describe 'GET /reports/categories/:category_id/items/:item_id/notifications' do
    let!(:notification_types) { create_list(:reports_notification_type, 3, category: category) }

    subject do
      get "/reports/categories/#{category.id}/items/#{item.id}/notifications", nil, auth(user)
    end

    context "didn't send any notification" do
      it 'returns all available notifications' do
        subject
        expect(response.status).to be_a_success_request

        entities = parsed_body['notifications']

        expect(entities.size).to eq(3)

        entities.each do |entity|
          expect(entity['sent']).to be_falsy
          expect(entity['able_to_send']).to be_truthy
          expect(entity['deadline_in_days']).to be_nil
        end
      end
    end

    context 'sent one notification' do
      let!(:sent_notification_type) { notification_types.sample }
      let!(:notification) do
        create(:reports_notification,
               notification_type: sent_notification_type,
               item: item
              )
      end

      it 'returns all available and sent notifications' do
        subject
        expect(response.status).to be_a_success_request

        entities = parsed_body['notifications']

        expect(entities.size).to eq(3)

        entities.each do |entity|
          if entity['id'] == notification.id && entity['kind'] == 'notification'
            expect(entity['sent']).to be_truthy
            expect(entity['able_to_send']).to be_truthy
            expect(entity['deadline_in_days']).to eq(notification.deadline_in_days)
          else
            expect(entity['kind']).to eq('notification_type')
            expect(entity['sent']).to be_falsy
            expect(entity['can_send_again']).to be_falsy
            expect(entity['deadline_in_days']).to be_nil
          end
        end
      end
    end
  end

  describe 'POST /reports/categories/:category_id/items/:item_id/notifications' do
    let!(:notification_types) do
      create_list(:reports_notification_type, 3,
                  category: category,
                  default_deadline_in_days: 15)
    end

    context 'valid item for sending' do
      before(:each) do
        Timecop.travel(Time.local(2015, 1, 1, 12, 0, 0))
      end

      after(:each) do
        Timecop.return
      end

      let(:notification_type) { notification_types.first }

      let(:params) do
        {
          notification_type_id: notification_type.id
        }
      end

      subject do
        post "/reports/categories/#{category.id}/items/#{item.id}/notifications", params, auth(user)
      end

      it 'creates the notification' do
        subject
        expect(response.status).to be_a_requisition_created

        notification = Reports::Notification.last
        expect(notification.item).to eq(item)
        expect(notification.notification_type).to eq(notification_type)
        expect(notification.deadline_in_days).to eq(15)
        expect(notification.days_to_deadline).to eq(15)
      end
    end

    context "notification type doesn't belong to item category" do
      let!(:notification_type) { create(:reports_notification_type) }
      let(:params) do
        {
          notification_type_id: notification_type.id,
          deadline_in_days: 15
        }
      end

      subject do
        post "/reports/categories/#{category.id}/items/#{item.id}/notifications", params, auth(user)
      end

      it 'returns an error' do
        subject
        expect(response.status).to be_a_not_found
      end
    end

    context "notification can't be sent" do
      let(:notification_type) { notification_types.first }

      let(:params) do
        {
          notification_type_id: notification_type.id,
          deadline_in_days: 15
        }
      end

      subject do
        post "/reports/categories/#{category.id}/items/#{item.id}/notifications", params, auth(user)
      end

      it 'creates the notification' do
        allow_any_instance_of(Reports::NotificationSendingManager).to \
          receive(:can_send_notification?).and_return(false)
        subject
        expect(response.status).to be_a_bad_request
      end
    end
  end

  describe 'GET /reports/categories/:category_id/items/:id/notifications/history' do
    let!(:active_notifications) { create_list(:reports_notification, 2, item: item) }
    let!(:inactive_notifications) { create_list(:reports_notification, 2, :inactive, item: item) }

    subject do
      get "/reports/categories/#{category.id}/items/#{item.id}/notifications/history", {}, auth(user)
    end

    it 'show all notifications of item' do
      subject

      notifications = parsed_body['notifications']
      expect(notifications.map { |c| c['id'] }).to match_array(active_notifications.map(&:id) + inactive_notifications.map(&:id))
    end
  end

  describe 'PUT /reports/categories/:category_id/items/:id/notifications/restart' do
    let!(:notification_types) { create_list(:reports_notification_type, 3, category: category) }
    let!(:notifications) do
      n = []

      notification_types.each do |notification_type|
        n << create(:reports_notification,
                    item: item,
                    notification_type: notification_type)
      end

      n
    end

    subject do
      put "/reports/categories/#{category.id}/items/#{item.id}/notifications/restart", nil, auth(user)
    end

    it 'removes the notifications and update the status' do
      previous_status = item.status
      notifications.first.update!(previous_status: item.status)
      Reports::UpdateItemStatus.new(item).update_status!(notification_types.first.status)

      subject
      expect(response.status).to be_a_success_request

      item.reload
      expect(Reports::Notification.for_item(item).active).to be_blank
      expect(item.status).to eq(previous_status)
      expect(parsed_body['current_status']['title']).to eq(item.status.title)
    end
  end

  describe 'GET /reports/categories/:category_id/items/:item_id/notifications/:id' do
    let(:notification) { create(:reports_notification, item: item) }

    subject do
      get "/reports/categories/#{category.id}/items/#{item.id}/notifications/#{notification.id}", nil, auth(user)
    end

    it 'returns the notification' do
      subject
      expect(response.status).to be_a_success_request

      expect(parsed_body['notification']).to be_an_entity_of(notification.reload)
      expect(parsed_body['notification']['current_status']['title']).to eq(item.status.title)
    end
  end

  describe 'GET /reports/categories/:category_id/items/:item_id/notifications/last' do
    let(:notifications) do
      create_list(:reports_notification, 3, item: item)
    end
    let!(:notification) { notifications.last }

    subject do
      get "/reports/categories/#{category.id}/items/#{item.id}/notifications/last", nil, auth(user)
    end

    it 'returns the notification' do
      subject
      expect(response.status).to be_a_success_request

      expect(parsed_body['notification']).to be_an_entity_of(notification.reload)
    end
  end

  describe 'PUT /reports/categories/:category_id/items/:item_id/notifications/:id/resend' do
    let(:notification_type) { create(:reports_notification_type, category: category) }
    let(:notification) do
      create(
        :reports_notification,
        item: item,
        notification_type: notification_type,
        deadline_in_days: 2.months,
        overdue_at: 1.day.from_now
      )
    end

    subject do
      put "/reports/categories/#{category.id}/items/#{item.id}/notifications/#{notification.id}/resend", nil, auth(user)
    end

    it 'restarts the due date' do
      subject
      expect(response.status).to be_a_success_request

      notification.reload
      expect(notification.active?).to be_falsey
    end
  end
end
