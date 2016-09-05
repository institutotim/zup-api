class SendReportThroughWebhook
  include Sidekiq::Worker

  sidekiq_options queue: :webhook, retry: 5, backtrace: true

  def perform(report_uuid, action = 'insert')
    if action == 'delete'
      Reports::DeleteThroughWebhook.new(report_uuid).delete!
    else
      report  = Reports::Item.find_by(uuid: report_uuid)
      service = Reports::SendThroughWebhook.new(report)

      if action == 'update'
        service.update!
      else
        service.insert!
      end

      report.sync_at = DateTime.now
      report.save!
    end
  end
end
