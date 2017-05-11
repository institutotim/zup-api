module Search::Reports::Items
  class API < Base::API
    desc 'Search for report items'
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
      optional :position, type: Hash,
               desc: 'Position parameters for search'
      optional :overdue, type: Boolean,
               desc: 'Rerturn only overdue or not overdue reports'
      optional :sort, type: String,
               desc: 'The field to sort the items. Either created_at, updated_at, status, id, reports_status_id (for status ordering) or user_name'
      optional :order, type: String,
               desc: 'The order, can be `desc` or `asc`'
      optional :display_type, type: String,
               desc: "Could be 'full'"
      optional :clusterize, type: String,
               desc: 'Should clusterize the results or not'
      optional :zoom, type: Integer,
               desc: 'Zooming level of the map'
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
      optional :with_notifications, type: Boolean,
               desc: 'Shows only report items with notifications sent'
      optional :reports_perimeters_ids, type: String,
               desc: 'Perimeters ids, format: "1,2,3"'
      optional :groups_ids, type: String,
               desc: 'Assigned groups ids, format: "1,2,3"'
    end
    get 'reports/items' do
      authenticate!

      search_params = safe_params.permit(
        :sort, :order, :page, :per_page, :begin_date, :end_date, :address,
        :query, :overdue, :clusterize, :zoom, :assigned_to_my_group, :assigned_to_me,
        :user_document, :flagged_offensive, :minimum_notification_number,
        :with_notifications, days_for_overdue_notification: [:begin, :end],
        days_since_last_notification: [:begin, :end], days_for_last_notification_deadline: [:begin, :end]
      )

      search_params[:paginator] = method(:paginate)
      search_params[:position] = safe_params[:position]

      unless safe_params[:groups_ids].blank?
        search_params[:group] = Group.find(safe_params[:groups_ids].split(','))
      end

      unless safe_params[:reports_perimeters_ids].blank?
        search_params[:perimeter] = Reports::Perimeter.find(safe_params[:reports_perimeters_ids].split(','))
      end

      unless safe_params[:reports_categories_ids].blank?
        search_params[:category] = Reports::Category.find(safe_params[:reports_categories_ids].split(','))
      end

      unless safe_params[:users_ids].blank?
        search_params[:user] = User.find(safe_params[:users_ids].split(','))
      end

      unless safe_params[:reporters_ids].blank?
        search_params[:reporter] = User.find(safe_params[:reporters_ids].split(','))
      end

      search_params[:begin_date] = safe_params[:begin_date]
      search_params[:end_date] = safe_params[:end_date]

      if safe_params[:statuses_ids].present?
        search_params[:statuses] = Reports::Status.find(safe_params[:statuses_ids].split(','))
      end

      results = Reports::SearchItems.new(current_user, search_params).search

      # If the param for return fields isn't nil, lets put some:
      if return_fields.blank?
        rfields = ReturnFieldsParams.new(
          'id,status_id,category_id,overdue,protocol,category.priority_pretty,address,' + \
          'user.id,user.name,reporter.id,reporter.name,category.title,assigned_group.name,' + \
          'assigned_group.title,assigned_user.name,assigned_user.id,created_at&sort=created_at'
        ).to_array
      else
        rfields = return_fields
      end

      if safe_params[:clusterize]
        header('Total', results[:total].to_s)

        {
          reports: Reports::Item::Entity.represent(results[:reports], only: rfields, display_type: safe_params[:display_type]),
          clusters: ClusterizeItems::Cluster::Entity.represent(results[:clusters])
        }
      else
        {
          reports: Reports::Item::Entity.represent(results, only: rfields,
                                                   display_type: safe_params[:display_type],
                                                   user: current_user)
        }
      end
    end

    desc 'Search for report items on given category and status'
    paginate per_page: 25
    params do
      optional :address
      optional :description
    end

    get 'reports/:category_id/status/:status_id/items' do
      authenticate!

      report_category = Reports::Category.find(safe_params[:category_id])
      status = Reports::Status.find(safe_params[:status_id])

      reports = Reports::Item.includes(:status).where(
        reports_category_id: report_category.id,
        reports_status_id: status.id
      )

      reports = reports.fuzzy_search({
        address: safe_params[:address],
        description:   safe_params[:description]
      }, false)

      reports = paginate(reports)

      {
        reports: Reports::Item::Entity.represent(reports,
                                                 user: current_user)
      }
    end
  end
end
