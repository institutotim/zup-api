module BusinessReports
  module Metrics
    class Base
      attr_reader :date_range, :params, :scope

      def initialize(date_range, params = {})
        @date_range = date_range
        @params = params
        @scope = nil
      end

      def fetch_data
        fail "You need to implement '#fetch_data' method for your metric class"
      end

      private

      def apply_categories_filter
        if params[:categories_ids]
          @scope = scope.where(reports_category_id: params[:categories_ids])
        end
      end

      def apply_date_range_filter
        @scope = scope.where(created_at: date_range)
      end
    end
  end
end
