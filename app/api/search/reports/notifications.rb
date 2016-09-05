module Search::Reports::Notifications
  class API < Base::API
    desc 'Search for report notification'
    paginate per_page: 25
    params do
      optional :begin_date, type: DateTime
      optional :end_date, type: DateTime
      optional :query, type: String, desc: 'Query for name of the user, title and protocol'
      optional :statuses_ids, type: String,
               desc: 'Statuses ids, format: "3,5,7"'
      optional :users_ids, type: String,
               desc: 'User ids, format: "3,5,7"'
      optional :reports_categories_ids, type: String,
               desc: 'Categories ids, format: "3,5,7"'
      optional :address, type: String
      optional :overdue, type: Boolean,
               desc: 'Rerturn only overdue or not overdue reports'
      optional :sort, type: String,
               desc: 'The field to sort the items. Either created_at, updated_at, status, id, reports_status_id (for status ordering) or user_name'
      optional :order, type: String,
               desc: 'The order, can be `desc` or `asc`'
      optional :display_type, type: String,
               desc: "Could be 'full'"
      optional :assigned_to_my_group, type: Boolean,
               desc: 'Show only reports assigned to my group'
      optional :assigned_to_me, type: Boolean,
               desc: 'Show only reports assigned to the signed user'
      optional :reporters_ids, type: String,
               desc: 'Reporter ids, format: "3,5,7"'
      optional :user_document, type: String,
               desc: 'User document, only numbers'
      optional :flagged_offensive, type: Boolean,
               desc: 'Show only reports flagged as offensive'
      optional :days_since_last_notification, type: Hash,
               desc: 'Filter report by the days since last notification'
      optional :days_for_last_notification_deadline, type: Hash,
               desc: 'Filter report by the days remaining to overdue the last notification'
      optional :minimum_notification_number, type: Integer,
               desc: 'Filter reports by the minimum count of notifications'
      optional :days_for_overdue_notification, type: Hash,
               desc: 'Filter reports by range the days remaining to overdue the last notification'
    end
    get 'reports/notifications' do
      authenticate!

      search_params = safe_params.permit(
        :begin_date, :end_date, :address, :query, :overdue, :assigned_to_my_group,
        :assigned_to_me, :user_document, :flagged_offensive, :minimum_notification_number,
        :order, :sort, :page, :per_page, days_for_overdue_notification: [:begin, :end],
        days_since_last_notification: [:begin, :end], days_for_last_notification_deadline: [:begin, :end]
      )

      search_params[:paginator] = method(:paginate)

      unless safe_params[:reports_categories_ids].blank?
        search_params[:category] = Reports::Category.find(safe_params[:reports_categories_ids].split(','))
      end

      unless safe_params[:users_ids].blank?
        search_params[:user] = User.find(safe_params[:users_ids].split(','))
      end

      unless safe_params[:reporters_ids].blank?
        search_params[:reporter] = User.find(safe_params[:reporters_ids].split(','))
      end

      if safe_params[:statuses_ids].present?
        search_params[:statuses] = Reports::Status.find(safe_params[:statuses_ids].split(','))
      end

      results = Reports::SearchNotifications.new(current_user, search_params).search

      { notifications: Reports::Notification::SearchReportEntity.represent(results, only: return_fields) }
    end
  end
end
