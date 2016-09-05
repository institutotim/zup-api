require 'app_helper'

describe Reports::NotificationLayoutParser do
  let(:notification) { create(:reports_notification) }

  subject { described_class.new(notification) }

  describe '#parsed_html' do
    let(:layout) do
      <<-HTML
        <html>
        <body>
          [[item_address]]
          [[user_name]]
          [[item_protocol]]
          [[notification_created_at]]
          [[notification_overdue_at]]
        </body>
        </html>
      HTML
    end

    before do
      notification.notification_type.update(layout: layout)
    end

    it 'replaces correctly the placeholders' do
      expect(subject.parsed_html).to_not include('item_address')
      expect(subject.parsed_html).to include(notification.item.full_address)
      expect(subject.parsed_html).to include(notification.item.user.name)
      expect(subject.parsed_html).to include(notification.item.protocol.to_s)
      expect(subject.parsed_html).to include(notification.created_at.strftime('%d/%m/%Y'))
      expect(subject.parsed_html).to include(notification.overdue_at.strftime('%d/%m/%Y'))
    end
  end
end
