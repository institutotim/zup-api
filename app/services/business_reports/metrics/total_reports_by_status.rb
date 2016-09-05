module BusinessReports
  module Metrics
    class TotalReportsByStatus < Base
      def fetch_data
        @scope = Reports::Item.select('reports_statuses.title AS title, COUNT(reports_items.id) AS count')
          .joins(:status)
          .group('reports_statuses.title')
          .order('count DESC')

        # Filters
        apply_date_range_filter
        apply_categories_filter

        ChartResult.new(
          {
            'Status' => :string,
            'Total' => :number
          },
          scope.map do |row|
            [row.title, row.count]
          end
        )
      end
    end
  end
end
