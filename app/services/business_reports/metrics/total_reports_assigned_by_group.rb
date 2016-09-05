module BusinessReports
  module Metrics
    class TotalReportsAssignedByGroup < Base
      def fetch_data
        @scope = Reports::Item.select('groups.name AS group_name, COUNT(reports_items.id) as count')
                              .joins(:category, :assigned_group)
                              .where('reports_categories.default_solver_group_id IS NOT NULL')
                              .group('groups.name')
                              .order('count DESC')

        # Filters
        apply_date_range_filter
        apply_categories_filter

        ChartResult.new(
          {
            'Grupo' => :string,
            'Total' => :number
          },
          scope.map do |row|
            [row.group_name, row.count]
          end
        )
      end
    end
  end
end
