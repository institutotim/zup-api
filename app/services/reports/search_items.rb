class Reports::SearchItems
  attr_reader :category, :user,
              :inventory_item, :position_params,
              :statuses, :begin_date,
              :end_date, :limit,
              :group_by_inventory_item, :sort,
              :order, :paginator, :page,
              :per_page, :address, :query,
              :signed_user, :overdue, :clusterize, :zoom,
              :assigned_to_my_group, :assigned_to_me, :reporter,
              :user_document, :flagged_offensive, :days_since_last_notification,
              :days_for_last_notification_deadline, :minimum_notification_number,
              :days_for_overdue_notification, :with_notifications,
              :perimeter, :permissions, :group

  def initialize(user, opts = {})
    opts.each do |key, value|
      instance_variable_set("@#{key}", value)
    end

    @signed_user     = user
    @position_params = opts.delete(:position)
    @permissions = UserAbility.for_user(signed_user)

    @category   ||= []
    @clusterize ||= false
    @sort       ||= 'created_at'
    @order      ||= 'desc'
    @page       ||= 1
    @per_page   ||= 25
  end

  def search
    initialize_scope
    build_inventory_filter
    build_grouped_inventory_filter
    build_query_filter
    build_document_filter
    build_user_filter
    build_report_filter
    build_category_filter
    build_perimeter_filter
    build_address_filter
    build_limit_filter
    build_created_date_filter
    build_overdue_filter
    build_statuses_filter
    build_assigned_group_filter
    build_group_filter
    build_assigned_filter
    build_offensive_flag_filter
    build_permissions_filter
    build_notification_filter
    build_last_notification_filter
    build_last_notification_deadline_filter
    build_overdue_notification_filter
    build_minimum_notification_filter
    build_sort_and_order_statement
    clusterize_or_return_scope
  end

  protected

  def initialize_scope
    @scope = Reports::Item.all.includes(:namespace)
  end

  def build_inventory_filter
    return unless inventory_item
    @scope = @scope.where(inventory_item_id: inventory_item.id)
  end

  def build_grouped_inventory_filter
    # Select only unique inventory_item_id
    return unless group_by_inventory_item

    @scope = @scope.select(
      <<-SQL
        DISTINCT ON (COALESCE(reports_items.inventory_item_id, reports_items.id)) reports_items.*
      SQL
    )
  end

  def build_query_filter
    return unless query

    @scope = @scope.joins(:user).search_by_query(query)
  end

  def build_document_filter
    return unless user_document

    @scope = @scope.joins(:user).search_by_user_document(user_document)
  end

  def build_user_filter
    users = Array(user)
    users_ids = users.map { |u| u.id }

    @scope = @scope.where(user_id: users_ids) if users_ids.any?
  end

  def build_report_filter
    reporters = Array(reporter)
    reporters_ids = reporters.map { |r| r.id }

    @scope = @scope.where(reporter_id: reporters_ids) if reporters_ids.any?
  end

  def build_category_filter
    categories = Array(category)
    categories_ids = categories.map { |c| c.id }

    if permissions.cannot?(:manage, Reports::Category)
      categories_user_can_see = permissions.reports_categories_visible_for_items

      if categories_ids.any?
        categories_ids = categories_user_can_see & categories_ids
      else
        categories_ids = categories_user_can_see
      end

      @scope = @scope.where(reports_category_id: categories_ids)
    elsif categories_ids.any?
      @scope = @scope.where(reports_category_id: categories_ids)
    end
  end

  def build_perimeter_filter
    perimeters = Array(perimeter)
    perimeters_ids = perimeters.map { |p| p.id }

    @scope = @scope.where(reports_perimeter_id: perimeters_ids) if perimeters_ids.any?
  end

  def build_address_filter
    if position_params
      @scope = Reports::SearchItemsByGeolocation.new(
        @scope, position_params, address
      ).scope_with_filters
    elsif address
      if address =~ /^[0-9]{5}-[0-9]{0,3}$/
        address.gsub!(/[^0-9]*/, '')
      end

      @scope = @scope.search_by_address(address)
    end
  end

  def build_limit_filter
    return unless limit
    @scope = @scope.limit(limit)
  end

  def build_created_date_filter
    if begin_date || end_date
      @begin_date = begin_date.try(:to_time)
      @end_date   = end_date.try(:to_time)

      if begin_date && end_date
        @scope = @scope.where('reports_items.created_at BETWEEN ? AND ?', begin_date, end_date)
      elsif begin_date
        @scope = @scope.where('reports_items.created_at >= ?', begin_date)
      elsif end_date
        @scope = @scope.where('reports_items.created_at <= ?', end_date)
      end
    end
  end

  def build_overdue_filter
    return unless overdue
    @scope = @scope.where(overdue: overdue)
  end

  def build_statuses_filter
    return unless statuses
    @scope = @scope.where('reports_status_id IN (?)', statuses.map(&:id))
  end

  def build_assigned_group_filter
    return unless assigned_to_my_group

    @scope = @scope.where(
      reports_items: {
        assigned_group_id: signed_user.groups.pluck(:id)
      }
    )
  end

  def build_group_filter
    groups = Array(group)
    groups_ids = groups.map { |g| g.id }

    @scope = @scope.joins(:assigned_group).where(groups: { id: groups_ids }) if groups_ids.any?
  end

  def build_assigned_filter
    return unless assigned_to_me

    @scope = @scope.where(
      reports_items: {
        assigned_user_id: signed_user.id
      }
    )
  end

  def build_offensive_flag_filter
    @scope = @scope.joins(:offensive_flags) if flagged_offensive
  end

  def build_permissions_filter
    if permissions.cannot?(:manage, Reports::Category)
      if permissions.reports_categories_with_editable_items.any?
        query = <<-SQL
          offensive = FALSE OR (offensive = TRUE AND reports_items.reports_category_id IN (?))
        SQL

        @scope = @scope.where(
          query, permissions.reports_categories_with_editable_items
        )
      else
        @scope = @scope.where(offensive: false)
      end
    end
  end

  def build_notification_filter
    @scope = @scope.joins(:notifications) if with_notifications
  end

  def build_last_notification_filter
    if days_since_last_notification && days_since_last_notification[:begin] && days_since_last_notification[:end]
      begin_date = days_since_last_notification[:begin]
      end_date = days_since_last_notification[:end]

      @scope = @scope.joins(:notifications)
                     .having(
                       '(current_date - DATE(MAX(reports_notifications.created_at))) BETWEEN ? and ?',
                       begin_date, end_date
                     ).group('reports_items.id')
    end
  end

  def build_last_notification_deadline_filter
    if days_for_last_notification_deadline && days_for_last_notification_deadline[:begin] && days_for_last_notification_deadline[:end]
      begin_date = days_for_last_notification_deadline[:begin]
      end_date = days_for_last_notification_deadline[:end]

      @scope = @scope.joins(:notifications)
                   .having(
                     '(DATE(MAX(reports_notifications.overdue_at)) - current_date) BETWEEN ? and ?',
                     begin_date, end_date
                   ).group('reports_items.id')
    end
  end

  def build_overdue_notification_filter
    if days_for_overdue_notification && days_for_overdue_notification[:begin] && days_for_overdue_notification[:end]
      begin_date = days_for_overdue_notification[:begin]
      end_date = days_for_overdue_notification[:end]

      @scope = @scope.joins(:notifications)
                     .having(
                       '(current_date - DATE(MAX(reports_notifications.overdue_at))) BETWEEN ? and ?',
                       begin_date, end_date
                     ).group('reports_items.id')
    end
  end

  def build_minimum_notification_filter
    return unless minimum_notification_number

    @scope = @scope.joins(:notifications)
                   .having(
                     'COUNT(reports_notifications.id) >= ?',
                      minimum_notification_number
                   ).group('reports_items.id')
  end

  def build_sort_and_order_statement
    if sort && !clusterize && valid_sort_and_order_values?
      @scope = Reports::Item.from("(#{@scope.to_sql}) reports_items")
                .joins(:user, :category, :status)
                .joins('LEFT JOIN groups ON groups.id = reports_items.assigned_group_id')
                .joins('LEFT JOIN users reports ON reports.id = reports_items.reporter_id')
                .joins(
                  <<-SQL
                    LEFT JOIN reports_category_settings settings
                    ON settings.reports_category_id = reports_items.reports_category_id
                    AND settings.namespace_id = reports_items.namespace_id
                  SQL
                )
                .where(reports_categories: { deleted_at: nil })
                .preload(
                  :category, :assigned_user, :reporter,
                  :assigned_group, :user, notifications: [:notification_type],
                  inventory_item: [data: [:field]]
                ).reorder(order_translated)

      @scope = paginator.call(@scope) if paginator.present?
    elsif position_params.blank?
      @scope = @scope.paginate(page: page, per_page: per_page)
    end
  end

  def clusterize_or_return_scope
    if position_params && clusterize
      ClusterizeItems::Reports.new(@scope, zoom).results
    else
      @scope
    end
  end

  def valid_sort_and_order_values?
    sort_fields.include?(sort) && %w(desc asc).include?(order.downcase)
  end

  def sort_fields
    %(created_at id protocol updated_at address status user reporter assignment
      category priority)
  end

  def sort_translated
    case sort
    when 'priority'     then 'settings.priority'
    when 'category'     then 'reports_categories.title'
    when 'status'       then 'reports_statuses.title'
    when 'user'         then 'users.name'
    when 'reporter'     then 'reports.name'
    when 'assignment'   then 'groups.name'
    when 'address'      then 'reports_items.address'
    else "reports_items.#{sort}"
    end
  end

  def order_translated
    if sort == 'address'
      <<-SQL
        LOWER(UNACCENT(reports_items.address)) #{order.downcase},
        TO_NUMBER('0'|| reports_items.number, '99999999999')::int #{order.downcase}
      SQL
    else
      "#{sort_translated} #{order.downcase}"
    end
  end
end
