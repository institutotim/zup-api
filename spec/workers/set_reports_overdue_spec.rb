require 'app_helper'

describe SetReportsOverdue do
  let!(:namespace) { Namespace.first_or_create(default: true, name: 'Namespace') }
  let(:category)   { create(:reports_category_with_statuses) }
  let(:setting)    { category.settings.find_by(namespace_id: namespace.id) }

  let(:already_marked_as_overdue_reports) { create_list(:reports_item, 2, :overdue) }
  let(:overdue_reports) { create_list(:reports_item, 2, category: category) }
  let(:not_overdue_reports) { create_list(:reports_item, 2, category: category) }

  before do
    setting.update!(resolution_time_enabled: true, resolution_time: 2.days.to_i)

    overdue_reports.each do |item|
      item.update(created_at: 3.days.ago)
      item.status_history.last.update(created_at: 3.days.ago)
    end

    not_overdue_reports.each do |item|
      item.update(created_at: 1.day.ago)
      item.status_history.last.update(created_at: 1.day.ago)
    end
  end

  subject { described_class.new.perform }

  describe '#perform' do
    it 'set overdue reports as overdue' do
      subject
      overdue_reports.each(&:reload)

      overdue_reports.each do |item|
        expect(item).to be_overdue
        expect(item.overdue_at).to_not be_blank
      end

      not_overdue_reports.each do |item|
        expect(item).to_not be_overdue
      end

      already_marked_as_overdue_reports.each do |item|
        expect(item).to be_overdue
      end
    end
  end
end
