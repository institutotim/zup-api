require 'app_helper'

describe Reports::Notification do
  let(:item)          { create(:reports_item) }
  let!(:notification) { create(:reports_notification, item: item) }

  describe '#current?' do
    it 'return true' do
      expect(notification.current?).to be_truthy
    end

    it 'return false' do
      create(:reports_notification, item: item)
      expect(notification.current?).to be_falsey
    end
  end
end
