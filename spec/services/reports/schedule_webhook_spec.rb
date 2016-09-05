require 'spec_helper'

describe Reports::ScheduleWebhook do
  let(:report)   { create(:reports_item) }
  let(:category) { create(:reports_category) }
  let(:status)   { create(:status) }

  subject { Reports::ScheduleWebhook.new(report) }

  describe '#schedule' do
    it 'schedule to delete when only old category is external' do
      allow(Webhook).to receive(:external_category?).with(category).and_return(false)
      allow(Webhook).to receive(:external_category?).with(report.category).and_return(true)

      expect(SendReportThroughWebhook).to receive(:perform_async).with(report.uuid, 'delete').and_return(true)

      report.category = category
      report.save

      subject.schedule
    end

    it 'schedule to insert when only new category is external' do
      allow(Webhook).to receive(:external_category?).with(category).and_return(true)
      allow(Webhook).to receive(:external_category?).with(report.category).and_return(false)

      expect(SendReportThroughWebhook).to receive(:perform_async).with(report.uuid, 'insert').and_return(true)

      report.category = category
      report.save

      subject.schedule
    end

    it 'schedule to update when boths categories are external' do
      allow(Webhook).to receive(:external_category?).with(category).and_return(true)
      allow(Webhook).to receive(:external_category?).with(report.category).and_return(true)

      expect(SendReportThroughWebhook).to receive(:perform_async).with(report.uuid, 'update').and_return(true)

      report.category = category
      report.save

      subject.schedule
    end

    it 'schedule to update when position changed' do
      expect(SendReportThroughWebhook).to receive(:perform_async).with(report.uuid, 'update').and_return(true)

      report.address = 'New Address'
      report.save

      subject.schedule
    end

    it 'schedule to update when status changed' do
      expect(SendReportThroughWebhook).to receive(:perform_async).with(report.uuid, 'update').and_return(true)

      report.status = status
      report.save

      subject.schedule
    end

    it 'do not schedule when overdue changed' do
      expect(SendReportThroughWebhook).to_not receive(:perform_async)

      report.overdue = true
      report.save

      subject.schedule
    end
  end
end
