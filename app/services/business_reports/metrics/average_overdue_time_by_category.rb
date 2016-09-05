module BusinessReports
  module Metrics
    class AverageOverdueTimeByCategory < BusinessReports::Metrics::Base
      def fetch_data
        @scope = Reports::Item
          .select('reports_categories.id, reports_categories.title AS title, avg(reports_items.overdue_at::date - reports_items.created_at::date)::integer AS days')
          .joins(:category)
          .where('reports_items.overdue = ? AND reports_items.overdue_at IS NOT NULL', true)
          .group('reports_categories.id')
          .order('days DESC')

        # Filters
        apply_date_range_filter
        apply_categories_filter

        ChartResult.new(
          {
            'Categoria' => :string,
            'Tempo médio de atraso (dias)' => :number
          },
          scope.map do |row|
            [row.title, row.days]
          end
        )
      end
    end
  end
end
