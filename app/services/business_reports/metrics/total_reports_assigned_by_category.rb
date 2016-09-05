module BusinessReports
  module Metrics
    class TotalReportsAssignedByCategory < Base
      def fetch_data
        @scope = Reports::Item.select('reports_categories.title AS category_title, groups.name AS group_name, COUNT(reports_items.id) as count')
                              .joins(:category, :assigned_group)
                              .where('reports_categories.default_solver_group_id IS NOT NULL')
                              .group('reports_categories.title, groups.name')
                              .order('count DESC')

        # Filters
        apply_date_range_filter
        apply_categories_filter

        ChartResult.new(
          {
            'Categoria' => :string,
            'Grupo' => :string,
            'Total' => :number
          },
          scope.map do |row|
            [row.category_title, row.group_name, row.count]
          end
        )
      end
    end
  end
end
