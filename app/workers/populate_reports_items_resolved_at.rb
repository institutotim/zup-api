class PopulateReportsItemsResolvedAt
  include Sidekiq::Worker

  def perform
    # Get all reports items and sets the correct `resolved_at` date
    Reports::Item.find_in_batches do |reports|
      reports.each do |report|
        status_relation = report.status.for_category(report.category, report.namespace_id)

        if status_relation.final?
          history = report.status_history.find_by(new_status_id: status_relation.reports_status_id)
          report.update(resolved_at: history.created_at) if history
        end
      end
    end
  end
end
