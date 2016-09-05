module BusinessReports
  module Metrics
    class AverageResolutionTimeByGroup < Base
      def fetch_data
        @scope = Reports::Item
          .select('groups.name AS name, avg(reports_items.resolved_at::date - reports_items.created_at::date)::integer AS days')
          .joins(:assigned_group)
          .where('reports_items.resolved_at IS NOT NULL')
          .group('groups.name')
          .order('days DESC')

        # Filters
        apply_date_range_filter
        apply_categories_filter

        ChartResult.new(
          {
            'Grupo' => :string,
            'Tempo médio de resolução (dias)' => :number
          },
          scope.map do |row|
            [row.name, row.days]
          end
        )
      end
    end
  end
end
