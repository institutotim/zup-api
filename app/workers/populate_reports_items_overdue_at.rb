class PopulateReportsItemsResolvedAt
  include Sidekiq::Worker

  def perform
    # Get all reports items and sets the correct `resolved_at` date
    Reports::Item.where(overdue: true).find_in_batches do |reports|
      reports.each do |report|
        history = report.histories.find_by(kind: overdue)
        report.update(overdue_at: history.created_at) if history
      end
    end
  end
end
