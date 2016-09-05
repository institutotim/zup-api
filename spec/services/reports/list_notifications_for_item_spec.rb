require 'app_helper'

describe Reports::ListNotificationsForItem, broken: true do
  let(:category) { create(:reports_category_with_statuses) }
  let(:item) { create(:reports_item, category: category) }
  let!(:notification_type) { create(:reports_notification_type, category: category) }

  subject { described_class.new(item) }

  describe '#fetch' do
    context 'no notifications were sent' do
      it 'returns the notification type entity' do
        entities = subject.fetch

        expect(entities.first).to match(
          id: notification_type.id,
          sent: false,
          user: nil,
          able_to_send: true,
          days_to_deadline: nil,
          deadline_in_days: nil,
          overdue_at: nil,
          previous_status: nil,
          content: '',
          item: a_kind_of(Hash),
          notification_type: a_kind_of(Hash),
          created_at: nil,
          updated_at: nil
        )
      end
    end

    context 'all notifications were sent' do
      let!(:notification) { create(:reports_notification, item: item, notification_type: notification_type) }

      it 'return the notification entity' do
        entities = subject.fetch

        expect(entities.first).to match(
          id: notification.id,
          sent: true,
          user: a_kind_of(Hash),
          able_to_send: true,
          days_to_deadline: notification.days_to_deadline,
          deadline_in_days: notification.deadline_in_days,
          overdue_at: notification.overdue_at,
          previous_status: nil,
          content: '',
          item: a_kind_of(Hash),
          notification_type: a_kind_of(Hash),
          created_at: notification.created_at,
          updated_at: notification.updated_at
        )
      end
    end
  end
end
