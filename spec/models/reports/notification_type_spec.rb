require 'app_helper'

describe Reports::NotificationType do
  context 'validations' do
    context 'with correct data' do
      it 'is valid' do
        notification_type = build(:reports_notification_type)
        expect(notification_type).to be_valid
      end
    end
  end
end
