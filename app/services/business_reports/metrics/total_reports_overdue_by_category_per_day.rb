module BusinessReports
  module Metrics
    class TotalReportsOverdueByCategoryPerDay < Base
      def fetch_data
        @scope = Reports::Item.joins(:category, :histories)
                              .where(overdue: true)
                              .where('reports_item_histories.kind = ?', :overdue)
                              .group('reports_categories.title, (current_date - reports_item_histories.created_at::date)')
                              .select('reports_categories.title AS title, (current_date - reports_item_histories.created_at::date) AS age_in_days, COUNT(reports_items.id) as count')
                              .order('count DESC')

        # Filters
        apply_date_range_filter
        apply_categories_filter

        ChartResult.new(
          {
            'Categoria' => :string,
            'Dias em atraso' => :number,
            'Total' => :number
          },
          scope.map do |row|
            [row.title, row.age_in_days, row.count]
          end
        )
      end
    end
  end
end
