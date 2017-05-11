module Reports::Items
  class API < Base::API
    desc 'Creates a new report'
    params do
      requires :category_id, type: Integer,
               desc: 'The ID of the desired report category'
      optional :inventory_item_id, type: Integer,
               desc: 'The ID of the inventory item for this report. If blank, latitude and longitude are mandatory.'
      optional :latitude, type: String,
               desc: 'The latitude for the custom location of this report. Ignored if an inventory item is given.'
      optional :longitude, type: String,
               desc: 'The longitude for the custom location of this report. Ignored if an inventory item is given.'
      optional :description, type: String,
               desc: 'The report description'
      # TODO: Geocode the address if not given and lat/long are present
      optional :address, type: String,
               desc: 'The complete address for this report.'
      optional :reference, type: String,
               desc: 'The reference for the address'
      optional :district, type: String
      optional :number, type: String
      optional :postal_code, type: String
      optional :city, type: String
      optional :state, type: String
      optional :country, type: String
      optional :images, type: Array,
               desc: 'An array of images(post data or encoded on base64) for this report.'
      optional :status_id, type: Integer,
               desc: 'The new status id'
      optional :user_id, type: Integer,
               desc: 'An user id to associate with it'
      optional :confidential, type: Boolean,
               desc: 'If the report is confidential or not'
      optional :from_panel, type: Boolean,
               desc: 'If the report is coming from the panel this should be true'
      optional :custom_fields, type: Hash,
               desc: 'The custom fields hash, id as key and value'
      optional :origin, type: String, default: 'panel',
              values: ['panel', 'app_android', 'app_ios', 'app_technical', 'web'],
              desc: 'The origin of the request'
    end
    post ':category_id/items' do
      authenticate!
      category = Reports::Category.find(params[:category_id])

      report_params = safe_params.permit(
        :description, :address, :reference, :confidential, :district,
        :number, :postal_code, :city, :state, :country, :origin
      )

      report_params.merge!(
        custom_fields: params[:custom_fields], namespace_id: app_namespace_id
      )

      Reports::Item.transaction do
        if params[:user_id]
          validate_permission!(:edit, Reports::Item)
          author = User.find(params[:user_id])
        else
          author = current_user
        end

        reporter = current_user

        report = Reports::Item.new(
          report_params.merge(category: category, user: author, reporter: reporter)
        )

        # Permission validation
        if safe_params.delete(:from_panel)
          validate_permission!(:create_from_panel, report)
        else
          validate_permission!(:create, report)
        end

        if params[:inventory_item_id]
          report.inventory_item = Inventory::Item.find(params[:inventory_item_id])
        else
          if (params[:latitude] && params[:longitude]) || params[:address]
            if params[:longitude] && params[:latitude]
              report.position = Reports::Item.rgeo_factory.point(params[:longitude], params[:latitude])
            end

            if params[:address]
              report.address = params[:address]
            end
          else
            error!('Either an inventory item or latitude, longitude, or address must be provided.', 400)
          end
        end

        report.update_images(params[:images]) if params[:images]
        report.save!
        report.reload

        if report.position.nil? && report.address.present?
          GeocodeReportsItem.perform_in(30.seconds, report.id)
        end

        if params[:inventory_item_id]
          Inventory::CreateHistoryEntry.new(report.inventory_item, current_user)
                                       .create('report',
                                               'Criou uma solicitação para este item de inventário.',
                                               report)
        end

        # Forward to default group
        setting = category.settings.find_by(namespace_id: app_namespace_id)

        if setting.default_solver_group || setting.perimeters?
          Reports::ForwardToGroup.new(report).forward_without_comment!(
            setting.default_solver_group
          )
        end

        if report.user
          Reports::NotifyUser.new(report).notify_report_creation!
        end

        if Webhook.enabled?
          SendReportThroughWebhook.perform_in(1.minutes, report.uuid)
        end

        Reports::CreateHistoryEntry.new(report, current_user)
                                   .create('creation',
                                           "Relato criado por #{current_user.name} no estado #{report.status.title}",
                                           new: report.status.entity(only: [:id, :title]))

        {
          report: Reports::Item::Entity.represent(report.reload,
                                                  display_type: 'full',
                                                  user: current_user,
                                                  only: return_fields)
        }
      end
    end

    desc 'Updates a report'
    params do
      optional :category_id, type: Integer,
               desc: 'The ID of the reports category of the report'
      optional :inventory_item_id, type: Integer,
               desc: 'The ID of the inventory item for this report. If blank, latitude and longitude are mandatory.'
      optional :latitude, type: String,
               desc: 'The latitude for the custom location of this report. Ignored if an inventory item is given.'
      optional :longitude, type: String,
               desc: 'The longitude for the custom location of this report. Ignored if an inventory item is given.'
      optional :description, type: String,
               desc: 'The report description'
      optional :address, type: String,
               desc: 'The complete address for this report.'
      optional :reference, type: String,
               desc: 'The reference for the address'
      optional :district, type: String
      optional :number, type: String
      optional :postal_code, type: String
      optional :city, type: String
      optional :state, type: String
      optional :country, type: String
      optional :status_id, type: String,
               desc: 'The new status of the item'
      optional :case_conductor_id, type: Integer,
               desc: 'The case conductor when a new case is created with status change'
      optional :images, type: Array,
               desc: 'An array of images(post data or encoded on base64) for this report.'
      optional :confidential, type: Boolean,
               desc: 'If the report is confidential or not'
      optional :version, type: Integer,
               desc: 'Sends the version together with the update for validation'
      optional :custom_fields, type: Hash,
               desc: 'The custom fields hash, id as key and value'
    end
    put ':reports_category_id/items/:id' do
      authenticate!

      category = Reports::Category.find(safe_params[:reports_category_id])
      report = Reports::Item.find_by!(id: safe_params[:id], reports_category_id: category.id)

      validate_permission!(:edit, report)

      if params[:version]
        Reports::ValidateVersion.new(report, params[:version]).validate!
      end

      Reports::Item.transaction do
        report_params = safe_params.permit(
          :description, :address, :reference, :confidential, :district,
          :number, :postal_code, :city, :state, :country, :offensive
        )

        report_params[:custom_fields] = params[:custom_fields]

        if safe_params[:category_id].present?
          new_category = Reports::Category.find(safe_params[:category_id])
          report_params = report_params.merge(
            category: new_category
          )
        end

        report.attributes = report_params

        if params[:inventory_item_id]
          report.inventory_item = Inventory::Item.find(
            params[:inventory_item_id]
          )
        elsif params[:latitude] && params[:longitude] && params[:address]
          report.position = Reports::Item.rgeo_factory.point(
            params[:longitude], params[:latitude]
          )
          report.address = params[:address]

          # Forward to default group
          setting = report.setting

          if setting.default_solver_group || setting.perimeters?
            Reports::ForwardToGroup.new(report).forward_without_comment!(
              setting.default_solver_group
            )
          end
        end

        report.update_images(params[:images]) if params[:images]
        report.save!

        if params[:status_id]
          new_status = category.statuses.find(params[:status_id])
          status_changer = Reports::UpdateItemStatus.new(report, current_user)
          status_changer.case_conductor = User.find(params[:case_conductor_id]) if params[:case_conductor_id]
          status_changer.update_status!(new_status)
        end

        create_history = Reports::CreateHistoryEntry.new(report, current_user)

        # Save history data
        if report.previous_changes[:address] || report.previous_changes[:description] || report.previous_changes[:reference]
          create_history.detect_changes_and_create!([:address, :description, :reference])
        end

        if Webhook.enabled?
          Reports::ScheduleWebhook.new(report).schedule
        end

        {
          report: Reports::Item::Entity.represent(
            report, display_type: 'full', user: current_user, only: return_fields
          )
        }
      end
    end

    desc 'Migrate report from category (and status)'
    params do
      optional :new_category_id, type: Integer,
               desc: 'The id of the new reports category of the report'
      optional :new_status_id, type: Integer,
               desc: 'The id of the new status of the new category to change'
    end
    put ':reports_category_id/items/:id/change_category' do
      authenticate!

      category = Reports::Category.find(safe_params[:reports_category_id])
      new_category = Reports::Category.find(safe_params[:new_category_id])
      item = Reports::Item.find_by!(id: safe_params[:id], reports_category_id: category.id)

      validate_permission!(:edit, item)

      new_status = new_category.statuses.find(safe_params[:new_status_id])

      # Move to new category and status
      service = Reports::ChangeItemCategory.new(item, new_category, new_status, current_user)
      service.process!

      if Webhook.enabled?
        action = Reports::ScheduleWebhook.new(item).action_by_category_change(category, new_category)
        SendReportThroughWebhook.perform_async(item.uuid, action)
      end

      # Ungroup report when category is changed
      if item.grouped?
        Reports::GroupItems.new(current_user, item).ungroup!
      end

      {
        report: Reports::Item::Entity.represent(
          item, display_type: 'full', user: current_user, only: return_fields
        )
      }
    end

    desc 'Forward report to another solver group'
    params do
      requires :group_id, type: Integer,
               desc: 'The id of the new group'
      optional :comment, type: String,
               desc: 'The comment to be created'
      optional :replicate, type: Boolean, default: false,
               desc: 'Replicate the change to grouped reports'
    end
    put ':reports_category_id/items/:id/forward' do
      authenticate!

      category = Reports::Category.find(params[:reports_category_id])
      group = Group.find(params[:group_id])
      item = Reports::Item.find_by!(id: params[:id], reports_category_id: category.id)
      comment = params[:comment]

      validate_permission!(:forward, item)

      # Forward to another group
      service = Reports::ForwardToGroup.new(item, current_user)
      service.forward!(group, comment)

      if params[:replicate]
        CopyToReportsItems.perform_async(current_user.id, item.id, 'group',
          comment: comment)
      end

      {
        report: Reports::Item::Entity.represent(
          item, display_type: 'full', user: current_user, only: return_fields
        )
      }
    end

    desc 'Assign report to an user'
    params do
      optional :user_id, type: Integer,
               desc: 'The id of the user assignee'
      optional :replicate, type: Boolean, default: false,
               desc: 'Replicate the change to grouped reports'
    end
    put ':reports_category_id/items/:id/assign' do
      authenticate!

      category = Reports::Category.find(params[:reports_category_id])
      user = User.find(params[:user_id])
      item = Reports::Item.find_by!(id: params[:id], reports_category_id: category.id)

      validate_permission!(:forward, item)

      # Forward to another group
      service = Reports::AssignToUser.new(item, current_user).assign!(user)

      if params[:replicate]
        CopyToReportsItems.perform_async(current_user.id, item.id, 'user')
      end

      {
        report: Reports::Item::Entity.represent(
          item, display_type: 'full', user: current_user, only: return_fields
        )
      }
    end

    desc 'Updates report status'
    params do
      requires :status_id, type: Integer,
               desc: 'The id of the status to change'
      optional :comment, type: String,
               desc: 'The comment to be created'
      optional :comment_visibility, type: Integer,
               desc: '0 = Public, 1 = Private'
      optional :case_conductor_id, type: Integer,
               desc: 'The user id to create the case, if it exists'
      optional :replicate, type: Boolean, default: false,
               desc: 'Replicate the change to grouped reports'
    end
    put ':reports_category_id/items/:id/update_status' do
      authenticate!

      category = Reports::Category.find(params[:reports_category_id])
      status = category.statuses.find(params[:status_id])
      item = Reports::Item.find_by!(id: params[:id], reports_category_id: category.id)
      comment = params[:comment]
      comment_visibility = params[:comment_visibility]
      case_conductor = User.find(params[:case_conductor_id]) if params[:case_conductor_id]

      validate_permission!(:alter_status, item)

      # Forward to another group
      service = Reports::UpdateItemStatus.new(item, current_user)
      service.case_conductor = case_conductor
      service.update_status!(status)

      if category.comment_required_when_updating_status || comment.present?
        service.create_comment!(comment, comment_visibility)
      end

      if Webhook.enabled?
        SendReportThroughWebhook.perform_async(item.uuid, 'update')
      end

      if params[:replicate]
        CopyToReportsItems.perform_async(current_user.id, item.id, 'status',
          comment: comment, visibility: comment_visibility)
      end

      options = { display_type: 'full', user: current_user, only: return_fields }
      options[:display_type] = 'full' unless params[:return_only]
      {
        report: Reports::Item::Entity.represent(
          item, options
        )
      }
    end

    # #####################
    # Endpoints for listing
    # #####################

    # TODO: remove other options for searching, make this the only
    # endpoint for listing reports.
    # TODO: Move this to a namespace "items"
    desc 'Retrieve a list of reports, you can use a list of params do filter'
    paginate per_page: 25
    params do
      optional :inventory_item_id, type: Integer,
               desc: 'Inventory item id to filter for'
      optional :category_id, type: Integer,
               desc: 'Report category to filter for'
      optional :user_id, type: Integer,
               desc: 'User id to filter for'
      optional :begin_date, type: DateTime,
               desc: 'The minimum date to filter'
      optional :end_date, type: DateTime,
               desc: 'The maximum date to filter'
      optional :statuses,
               desc: "Statuses id to filter, you can
               pass a single id or an array of ids"
      optional :display_type, type: String,
               desc: 'Display type for report data'
      optional :limit, type: Integer,
               desc: 'The maximum number to reports to return'
      optional :sort, type: String,
               desc: 'The field to sort the items. Either created_at, updated_at, id, reports_status_id or user_name'
      optional :order, type: String,
               desc: 'Either ASC or DESC.'
      optional :clusterize, type: String,
               desc: 'Should clusterize the results or not'
    end
    get 'items' do
      if safe_params[:category_id]
        category = Reports::Category.find(safe_params[:category_id])
      end

      if safe_params[:user_id]
        user = User.find(safe_params[:user_id])
      end

      if safe_params[:inventory_item_id]
        inventory_item = Inventory::Item.find(safe_params[:inventory_item_id])
      end

      if safe_params[:begin_date]
        begin_date = safe_params[:begin_date]
      end

      if safe_params[:end_date]
        end_date = safe_params[:end_date]
      end

      if safe_params[:statuses]
        if safe_params[:statuses].is_a? Array
          statuses = safe_params[:statuses].map do |status_id|
            Reports::Status.find(status_id)
          end
        else
          statuses = [Reports::Status.find(safe_params[:statuses])]
        end
      end

      reports = Reports::SearchItems.new(
        current_user,
        category: category,
        user: user,
        inventory_item: inventory_item,
        position: safe_params[:position],
        statuses: statuses,
        begin_date: begin_date,
        end_date: end_date,
        group_by_inventory_item: true,
        limit: safe_params[:limit],
        sort: safe_params[:sort],
        order: safe_params[:order],
        paginator: method(:paginate),
        page: safe_params[:page],
        per_page: safe_params[:per_page],
        clusterize: safe_params[:clusterize]
      )

      reports = reports.search

      garner.bind(Reports::ItemCacheControl.new(reports)).options(expires_in: 15.minutes) do
        {
          reports: Reports::Item::Entity.represent(
            reports,
            display_type: safe_params[:display_type],
            user: current_user,
            only: return_fields,
            serializable: true
          )
        }
      end
    end

    # TODO: Move to a namespace "items"
    desc 'Returns data for report'
    params do
      optional :display_type, type: String,
               desc: 'Display type for report data'
      requires :id, type: Integer, desc: "The report's ID"
    end
    get 'items/:id' do
      report = Reports::Item.find(safe_params[:id])

      {
        report: Reports::Item::Entity.represent(
          report,
          user: current_user,
          only: return_fields,
          display_type: 'full'
        )
      }
    end

    desc 'Destroy a report item'
    params do
      requires :id, type: Integer, desc: "The report's ID"
    end
    delete 'items/:id' do
      authenticate!

      report = Reports::Item.find(params[:id])
      validate_permission!(:delete, report)

      if report.destroy
        if Webhook.enabled?
          SendReportThroughWebhook.perform_async(report.uuid, 'delete')
        end

        status 204
      else
        status 422
      end
    end

    desc 'Retrieve a list of reports assigned to the given category'
    paginate per_page: 25
    params do
      requires :category_id, type: Integer,
               desc: 'The report category ID'
      optional :position, type: Hash,
               desc: 'Position parameters for search'
      optional :display_type, type: String,
               desc: 'Display type for report'
      optional :limit, type: Integer,
               desc: 'The maximum number to reports to return'
      optional :sort, type: String,
               desc: 'The field to sort the items. Either created_at, updated_at or id'
      optional :order, type: String,
               desc: 'Either ASC or DESC.'
    end
    get ':category_id/items' do
      category = Reports::Category.find(params[:category_id])
      position = safe_params[:position]
      reports  = Reports::SearchItems.new(
        current_user,
        category: category,
        position: position,
        limit: safe_params[:limit],
        sort: safe_params[:sort],
        order: safe_params[:order],
        paginator: method(:paginate)
      ).search

      {
        reports: Reports::Item::Entity.represent(
          reports,
          user: current_user,
          only: return_fields,
          display_type: safe_params[:display_type]
        )
      }
    end

    desc 'Retrieve a list of reports assigned to the given inventory item'
    paginate per_page: 25
    params do
      requires :inventory_item_id, type: Integer,
               desc: 'The inventory item ID'
      optional :position, type: Hash,
               desc: 'Position parameters for search'
      optional :display_type, type: String,
               desc: 'Display type for report'
      optional :limit, type: Integer,
               desc: 'The maximum number to reports to return'
    end
    get 'inventory/:inventory_item_id/items' do
      item = Inventory::Item.find(params[:inventory_item_id])
      position = safe_params[:position]
      reports  = Reports::SearchItems.new(
        current_user,
        inventory_item: item,
        position: position,
        limit: safe_params[:limit],
        sort: safe_params[:sort],
        order: safe_params[:order],
        paginator: method(:paginate)
      ).search

      {
        reports: Reports::Item::Entity.represent(
          reports,
          user: current_user,
          only: return_fields,
          display_type: safe_params[:display_type]
        )
      }
    end

    desc 'Retrieve a list of reports assigned to the current user'
    paginate per_page: 25
    params do
      optional :display_type, type: String,
               desc: 'Display type for report'
      optional :position, type: Hash,
               desc: 'Position parameters for search'
      optional :limit, type: Integer,
               desc: 'The maximum number to reports to return'
    end
    get 'users/me/items' do
      authenticate!

      position = safe_params[:position]
      reports  = Reports::SearchItems.new(
        current_user,
        user: current_user,
        position: position,
        limit: safe_params[:limit]
      ).search

      total_reports_by_user = current_user.reports.count

      {
        reports: Reports::Item::Entity.represent(
          reports,
          user: current_user,
          only: return_fields,
          display_type: 'full'
        ),
        total_reports_by_user: total_reports_by_user
      }
    end

    desc 'Retrieve a list of reports assigned to the given user'
    paginate per_page: 25
    params do
      requires :user_id, type: Integer,
               desc: 'The user id'
      optional :display_type, type: String,
               desc: 'Display type for report item'
      optional :position, type: Hash,
               desc: 'Position parameters for search'
      optional :limit, type: Integer,
               desc: 'The maximum number to reports to return'
    end
    get 'users/:user_id/items' do
      user = User.find(params[:user_id])
      position = safe_params[:position]
      reports  = Reports::SearchItems.new(
        current_user,
        user: user,
        position: position,
        limit: safe_params[:limit]
      ).search

      total_reports_by_user = user.reports.count

      {
        reports: Reports::Item::Entity.represent(
          reports,
          only: return_fields,
          user: current_user,
          display_type: 'full'
        ),
        total_reports_by_user: total_reports_by_user
      }
    end
  end
end
