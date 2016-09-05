module BusinessReports
  module Metrics
    class TotalReportsUnassignedToUser < Base
      def fetch_data
        @scope = Reports::Item.select('reports_categories.title AS category_title, COUNT(reports_items.id) as count')
                              .joins(:category, :assigned_group)
                              .where('reports_categories.default_solver_group_id IS NOT NULL')
                              .where('reports_items.assigned_user_id IS NULL')
                              .group('reports_categories.title')
                              .order('count DESC')

        # Filters
        apply_date_range_filter
        apply_categories_filter

        ChartResult.new(
           {
            'Categoria' => :string,
            'Total' => :number
          },
          scope.map do |row|
            [row.category_title, row.count]
          end,
        )
      end
    end
  end
end
