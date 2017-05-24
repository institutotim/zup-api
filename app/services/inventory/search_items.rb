class Inventory::SearchItems
  attr_reader :fields, :categories, :position_params,
              :limit, :sort, :order, :address, :statuses,
              :created_at, :updated_at, :title, :users,
              :query, :user, :clusterize, :zoom, :page, :per_page,
              :paginator, :permissions

  def initialize(user, opts = {})
    @user = user
    @permissions = UserAbility.for_user(user)

    @categories = opts.fetch(:categories) { [] }
    @order = opts.fetch(:order) { 'desc' }
    @per_page = opts.fetch(:per_page) { 25 }
    @sort = opts.fetch(:sort) { 'id' }
    @statuses = opts.fetch(:statuses) { [] }
    @users = opts.fetch(:users) { [] }

    @address = opts[:address]
    @clusterize = opts[:clusterize]
    @created_at = opts[:created_at]
    @fields = opts[:fields] || {}
    @limit = opts[:limit]
    @position_params = opts[:position]
    @page = opts[:page]
    @paginator = opts[:paginator]
    @query = opts[:query]
    @title = opts[:title]
    @updated_at = opts[:updated_at]
    @zoom = opts[:zoom]
  end

  def search
    initialize_scope
    build_query_filter
    build_categories_filter
    build_statuses_filter
    build_users_filter
    build_title_filter
    build_position_filter
    build_created_at_filter
    build_updated_at_filter
    build_limite_filter
    build_fields_filter
    build_sort_and_order_statement
    clusterize_or_return_scope
  end

  private

  def initialize_scope
    @scope = Inventory::Item.includes(:category, :user, :namespace)
                            .joins(
                              <<-SQL
                                INNER JOIN inventory_categories ic ON ic.id = inventory_items.inventory_category_id
                                AND ic.deleted_at IS NULL
                              SQL
                            )
  end

  def build_query_filter
    return unless query

    @scope = @scope.search_by_query(query)
  end

  def build_categories_filter
    categories_ids = categories.map(&:id) if categories.any?

    if permissions.cannot?(:manage, Inventory::Category)
      categories_user_can_see = permissions.inventory_categories_visible

      if categories_ids && categories_ids.any?
        categories_ids = categories_user_can_see & categories_ids
      else
        categories_ids = categories_user_can_see
      end

      if user
        permission_statement = ''
        Inventory::Category.where(id: categories_ids).each_with_index do |category, i|
          if i > 0
            permission_statement += ' OR '
          end

          if permissions.can?(:view_all_items, category)
            permission_statement += "(inventory_category_id = #{category.id})"
          else
            permission_statement += "(inventory_category_id = #{category.id} AND user_id = #{user.id})"
          end
        end
      end

      if permission_statement.blank?
        permission_statement = { inventory_category_id: categories_ids }
      end

      @scope = @scope.where(permission_statement)
    elsif categories_ids && categories_ids.any?
      @scope = @scope.where(inventory_category_id: categories_ids)
    end
  end

  def build_statuses_filter
    return unless statuses.any?
    @scope = @scope.where(inventory_status_id: statuses.map(&:id))
  end

  def build_users_filter
    return unless users.any?
    @scope = @scope.where(user_id: users.map(&:id))
  end

  def build_title_filter
    return unless title
    @scope = @scope.search_by_title(title)
  end

  def build_position_filter
    if position_params
      # If it is a simple hash, transform to complex one
      position_hash = if position_params.key?(:latitude)
                        { 0 => position_params }
                      else
                        position_params
                      end

      statement = ''
      position_hash.each do |_index, p|
        latlon = "POINT(#{p[:longitude].to_f} #{p[:latitude].to_f})"

        unless statement.blank?
          statement += ' OR '
        end

        statement += <<-SQL
          ST_DWithin(
            ST_GeomFromText('#{latlon}', 4326)::geography,
            inventory_items.position, #{p[:distance].to_i}
          )
        SQL
      end

      if address
        statement += <<-SQL
          OR inventory_items.address ILIKE ?
        SQL

        @scope = @scope.where(statement, "%#{address}%")
      else
        @scope = @scope.where(statement)
      end
    elsif address
      @scope = @scope.search_by_address(address)
    end
  end

  def build_created_at_filter
    if created_at && (created_at[:begin] || created_at[:end])
      if created_at[:begin] && created_at[:end]
        begin_date = DateTime.parse(created_at[:begin])
        end_date = DateTime.parse(created_at[:end])

        @scope = @scope.where(inventory_items: { created_at: begin_date..end_date })
      elsif created_at[:begin]
        begin_date = DateTime.parse(created_at[:begin])
        @scope = @scope.where('inventory_items.created_at >= ?', begin_date)
      elsif created_at[:end]
        end_date = DateTime.parse(created_at[:end])
        @scope = @scope.where('inventory_items.created_at <= ?', end_date)
      end
    end
  end

  def build_updated_at_filter
    if updated_at && (updated_at[:begin] || updated_at[:end])
      if updated_at[:begin] && updated_at[:end]
        begin_date = DateTime.parse(updated_at[:begin])
        end_date = DateTime.parse(updated_at[:end])

        @scope = @scope.where(updated_at: begin_date..end_date)
      elsif updated_at[:begin]
        begin_date = DateTime.parse(updated_at[:begin])
        @scope = @scope.where('updated_at >= ?', begin_date)
      elsif updated_at[:end]
        end_date = DateTime.parse(updated_at[:end])
        @scope = @scope.where('updated_at <= ?', end_date)
      end
    end
  end

  def build_limite_filter
    return unless limit
    @scope = @scope.limit(limit)
  end

  def build_fields_filter
    return unless fields.any?
    @scope = Inventory::SearchItemsByFields.new(@scope, fields).scope_with_filters
  end

  def build_sort_and_order_statement
    if sort && !clusterize && valid_sort_and_order_values?
      if sort == 'title'
        @scope = @scope.reorder("inventory_items.title #{order}, inventory_items.sequence #{order}")
      else
        @scope = @scope.reorder("#{sort_translated} #{order.downcase}")
      end

      if paginator.present?
        @scope = paginator.call(@scope)
      end
    elsif position_params.blank?
      @scope = @scope.paginate(page: page, per_page: per_page)
    end
  end

  def clusterize_or_return_scope
    if position_params && clusterize
      ClusterizeItems::Inventory.new(@scope, zoom).results
    else
      @scope
    end
  end

  def valid_sort_and_order_values?
    sort_fields.include?(sort) && %w(desc asc).include?(order.downcase)
  end

  def sort_fields
    %w(id address title created_at updated_at inventory_category_id category_title user_name)
  end

  def sort_translated
    case sort
    when 'user_name'      then 'users.name'
    when 'category_title' then 'inventory_categories.title'
    else "inventory_items.#{sort}"
    end
  end
end
