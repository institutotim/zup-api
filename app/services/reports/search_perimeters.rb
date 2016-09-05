module Reports
  class SearchPerimeters
    SORT_FIELDS = %w(id title status created_at priority active)

    attr_accessor :title, :sort, :order, :paginate, :paginator

    def initialize(params)
      @title = params[:title]
      @sort = params[:sort] || 'priority'
      @order = params[:order] || 'desc'
      @paginate = params[:paginate]
      @paginator = params[:paginator]
    end

    def search
      scope = Reports::Perimeter.preload(:group)

      if title
        scope = scope.search_by_title(title)
      end

      if sort && SORT_FIELDS.include?(sort)
        unless %w(desc asc).include?(order.downcase)
          @order = 'asc'
        end

        scope = scope.reorder("#{sort} #{order.downcase}")
      end

      if paginate && paginator
        scope = paginator.call(scope)
      end

      scope
    end
  end
end
