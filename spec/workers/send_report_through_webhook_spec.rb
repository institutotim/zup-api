require 'app_helper'

describe SendReportThroughWebhook do
  let(:report) { create(:reports_item) }

  context '#perform' do
    it 'delete insert a report through webhook' do
      expect_any_instance_of(Reports::DeleteThroughWebhook).to receive(:delete!)
      SendReportThroughWebhook.new.perform(report.uuid, 'delete')
    end

    it 'insert a report through webhook' do
      expect_any_instance_of(Reports::SendThroughWebhook).to receive(:insert!)
      SendReportThroughWebhook.new.perform(report.uuid)
      expect(report.reload.sync_at).to_not be_nil
    end

    it 'update a report through webhook' do
      expect_any_instance_of(Reports::SendThroughWebhook).to receive(:update!)
      SendReportThroughWebhook.new.perform(report.uuid, 'update')
      expect(report.reload.sync_at).to_not be_nil
    end
  end
end
