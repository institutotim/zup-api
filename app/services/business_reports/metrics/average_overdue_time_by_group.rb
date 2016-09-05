module BusinessReports
  module Metrics
    class AverageOverdueTimeByGroup < Base
      def fetch_data
        @scope = Reports::Item
          .select('groups.name AS name, avg(reports_items.overdue_at::date - reports_items.created_at::date)::integer AS days')
          .joins(:assigned_group)
          .where('reports_items.overdue = ? AND reports_items.overdue_at IS NOT NULL', true)
          .group('groups.name')
          .order('days DESC')

        # Filters
        apply_date_range_filter
        apply_categories_filter

        ChartResult.new(
          {
            'Grupo' => :string,
            'Tempo médio de atraso (dias)' => :number
          },
          scope.map do |row|
            [row.name, row.days]
          end
        )
      end
    end
  end
end
