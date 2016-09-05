module BusinessReports
  module Metrics
    class TotalReportsByCategory < Base
      def fetch_data
        @scope = Reports::Item.joins(:category).group('reports_categories.title')

        # Filters
        apply_date_range_filter
        apply_categories_filter

        @scope = scope.count

        ChartResult.new(
          {
            'Categoria' => :string,
            'Total' => :number
          },
          scope.map do |row|
            [row[0], row[1]]
          end
        )
      end
    end
  end
end
