module Reports
  class SearchNotifications
    attr_reader :user,
                :params,
                :page,
                :per_page,
                :paginator,
                :sort,
                :order,
                :days_since_last_notification,
                :days_for_last_notification_deadline,
                :days_for_overdue_notification

    def initialize(user, opts = {})
      @user = user
      @days_since_last_notification        = opts.delete(:days_since_last_notification)
      @days_for_last_notification_deadline = opts.delete(:days_for_last_notification_deadline)
      @days_for_overdue_notification       = opts.delete(:days_for_overdue_notification)
      @page      = opts.delete(:page)     || 1
      @per_page  = opts.delete(:per_page) || 25
      @sort      = opts.delete(:sort)     || 'created_at'
      @order     = opts.delete(:order)    || 'desc'
      @paginator = opts.delete(:paginator)
      @params    = opts
    end

    def search
      items_scope = Reports::SearchItems.new(user, params).search

      scope = Reports::Notification.where("reports_notifications.reports_item_id in (#{items_scope.select(:id).to_sql})")

      scope = search_by_days_for_last_notification_deadline(scope)
      scope = search_by_days_for_overdue_notification(scope)
      scope = search_by_days_since_last_notification(scope)

      if sort
        @sort  = 'created_at' unless %w(created_at updated_at id).include?(sort)
        @order = 'desc'       unless %w(desc asc).include?(order)

        scope = scope.order("reports_notifications.#{sort} #{order}")
      end

      if paginator.present?
        scope = paginator.call(scope)
      end

      scope.preload(:notification_type, :user, item: [:category, :notifications])
    end

    protected

    def search_by_days_since_last_notification(scope)
      if days_since_last_notification && days_since_last_notification[:begin] && days_since_last_notification[:end]
        scope = scope.where(
          '(current_date - DATE(reports_notifications.created_at)) BETWEEN ? and ?',
          days_since_last_notification[:begin], days_since_last_notification[:end]
        )
      end

      scope
    end

    def search_by_days_for_last_notification_deadline(scope)
      if days_for_last_notification_deadline && days_for_last_notification_deadline[:begin] && days_for_last_notification_deadline[:end]
        scope = scope.where(
          '(DATE(reports_notifications.overdue_at) - current_date) BETWEEN ? and ?',
          days_for_last_notification_deadline[:begin], days_for_last_notification_deadline[:end]
        )
      end

      scope
    end

    def search_by_days_for_overdue_notification(scope)
      if days_for_overdue_notification && days_for_overdue_notification[:begin] && days_for_overdue_notification[:end]
        scope = scope.where(
          '(current_date - DATE(reports_notifications.overdue_at)) BETWEEN ? and ?',
          days_for_overdue_notification[:begin], days_for_overdue_notification[:end]
        )
      end

      scope
    end
  end
end
