require 'app_helper'

describe Reports::NotificationSendingManager do
  let(:item)     { create(:reports_item) }
  let(:category) { item.category }
  let(:user)     { create(:user) }
  let(:setting)  { category.settings.find_by(namespace_id: item.namespace_id) }

  # Create notification types for the category
  let!(:notification_types) { create_list(:reports_notification_type, 3, category: category)  }

  before do
    notification_types.each_with_index do |nt, i|
      nt.update!(order: i)
    end
  end

  subject { described_class.new(item, user) }

  describe '#can_send_notification?' do
    context 'with sent notification' do
      let!(:notification) do
        create(
          :reports_notification,
          notification_type: notification_types.first,
          item: item
        )
      end

      context 'notification is not overdue' do
        it 'returns true' do
          expect(subject.can_send_notification?(notification)).to be_truthy
        end
      end

      context 'notification was already overdue' do
        before do
          notification.update!(overdue_at: 2.days.ago)
        end

        it 'returns false' do
          expect(subject.can_send_notification?(notification)).to be_falsy
        end
      end

      context 'notification have not overdue' do
        before do
          notification.update!(overdue_at: nil)
        end

        it 'returns true' do
          expect(subject.can_send_notification?(notification)).to be_truthy
        end
      end
    end
  end

  context 'with notification type' do
    context 'ordered' do
      before do
        setting.update!(ordered_notifications: true)
      end

      context 'notification type is the first to be sent' do
        let(:notification_type) { notification_types.first }

        it 'returns true' do
          expect(subject.can_send_notification?(notification_type)).to be_truthy
        end
      end

      context 'notification type is not the next in order' do
        let(:notification_type) { notification_types.last }
        before { create(:reports_notification, notification_type: notification_types.first, item: item) }

        it 'returns false' do
          expect(subject.can_send_notification?(notification_type)).to be_falsy
        end
      end
    end

    context 'not ordered' do
      let(:notification_type) { notification_types[1] }

      it 'returns true' do
        expect(subject.can_send_notification?(notification_type)).to be_truthy
      end
    end
  end

  describe '#create!' do
    let(:notification_type) { notification_types.first }
    let(:params) do
      {
        reports_notification_type_id: notification_type.id
      }
    end

    before do
      notification_type.update(status: nil)
    end

    it 'creates the notification' do
      notification = subject.create!(params)

      expect(notification).to be_persisted
      expect(notification.deadline_in_days).to eq(notification_type.default_deadline_in_days)
      expect(item.histories.reload.last.kind).to eq('notification')
    end

    context 'notification type without `default_deadline_in_days`' do
      before do
        notification_type.update(status: nil, default_deadline_in_days: 0)
      end

      it 'creates the notification without overdue' do
        notification = subject.create!(params)

        expect(notification).to be_persisted
        expect(notification.deadline_in_days).to eq(notification_type.default_deadline_in_days)
        expect(notification.overdue_at).to be_nil
        expect(item.histories.reload.last.kind).to eq('notification')
      end
    end

    context 'notification type with status' do
      let(:status) { create(:status) }

      let!(:status_category) do
        create(:reports_status_category, status: status, category: category, color: '#ff0000')
      end

      before do
        notification_type.update(status: status)
      end

      it 'updates the item status' do
        previous_status = item.status
        notification = subject.create!(params)
        item.reload

        expect(item.status).to eq(status)
        expect(notification.previous_status).to eq(previous_status)
      end
    end
  end

  describe '#restart!' do
    let(:notification_type) { notification_types.first }
    let(:notification) do
      create(
        :reports_notification,
        item: item,
        notification_type: notification_type
      )
    end

    context 'item with status unchanged' do
      before do
        notification
      end

      it 'restarts the process by disabling all notifications from the item' do
        previous_status = item.status
        subject.restart!
        expect(Reports::Notification.for_item(item).active).to be_blank
        expect(item.reload.status).to eq(previous_status)
        expect(item.histories.last.kind).to eq('notification_restart')
      end
    end

    context 'item with status changed by notification' do
      before do
        notification.update!(previous_status: item.status)
      end

      context 'unordered notifications' do
        it 'restarts the process by disabling all notifications and updating the status back' do
          previous_status = item.status
          Reports::UpdateItemStatus.new(item).update_status!(notification_type.status)
          subject.restart!
          expect(Reports::Notification.for_item(item).active).to be_blank
          expect(item.reload.status).to eq(previous_status)
        end
      end

      context 'ordered notifications' do
        before do
          category.update!(ordered_notifications: true)
          notification.update!(previous_status: item.status)
        end

        it 'restarts the process by disabling all notifications and updating status back' do
          previous_status = item.status
          Reports::UpdateItemStatus.new(item).update_status!(notification_type.status)
          subject.restart!
          expect(Reports::Notification.for_item(item).active).to be_blank
          expect(item.reload.status).to eq(previous_status)
        end
      end
    end
  end

  describe '#resend!' do
    let(:notification_type) { notification_types.first }
    let(:notification) { create(:reports_notification, deadline_in_days: 2.months, item: item, notification_type: notification_type) }

    it 'inactive the notification and create new one' do
      notification.update(overdue_at: 1.day.from_now)

      new_notification = subject.resend!(notification)
      notification.reload

      expect(new_notification.overdue_at).to be > 1.day.from_now
      expect(notification.active?).to be_falsey
    end
  end
end
