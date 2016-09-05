module Reports
  module NotificationTypes
    class API < Grape::API
      helpers do
        def load_category
          Reports::Category.find(params[:category_id])
        end

        def load_notification_type(id = params[:id])
          Reports::NotificationType.find(id)
        end
      end

      namespace 'categories/:category_id/notification_types' do
        desc 'List all notification types for the category'
        params do
          optional :deactivated, type: Boolean, desc: 'Shows deactivated notification types'
        end
        get do
          authenticate!
          category = load_category
          validate_permission!(:view, category)

          notification_types = Reports::NotificationType.for_category(category, app_namespace_id)

          unless params[:deactivated]
            notification_types = notification_types.active
          end

          {
            notification_types: Reports::NotificationType::Entity.represent(notification_types,
                                                                            only: return_fields)
          }
        end

        desc 'Creates a new notification type'
        params do
          requires :title, type: String
          requires :layout, type: String
          optional :default_deadline_in_days, type: Integer
          optional :order, type: Integer
          optional :reports_status_id, type: Integer
        end
        post do
          authenticate!
          category = load_category

          validate_permission!(:edit, category)

          notification_type_params = safe_params.permit(
            :title, :default_deadline_in_days, :layout, :order, :reports_status_id
          )

          notification_type_params.merge!(namespace_id: app_namespace_id, category: category)

          notification_type = Reports::NotificationType.create!(
            notification_type_params
          )

          present notification_type, only: return_fields
        end

        desc 'Updates a notification type'
        params do
          optional :title, type: String
          optional :default_deadline_in_days, type: Integer
          optional :layout, type: String
          optional :order, type: Integer
          optional :reports_status_id, type: Integer
        end
        put ':id' do
          authenticate!
          category = load_category
          notification_type = load_notification_type

          validate_permission!(:edit, category)

          notification_type_params = safe_params.permit(
            :title, :default_deadline_in_days, :layout, :order, :reports_status_id
          )

          notification_type.update!(
            notification_type_params
          )

          present notification_type, only: return_fields
        end

        desc 'Deletes a notification type'
        delete ':id' do
          authenticate!
          category = load_category
          notification_type = load_notification_type

          validate_permission!(:edit, category)

          notification_type.deactivate!

          {
            message: I18n.t(:'reports.notification_types.delete.success')
          }
        end
      end
    end
  end
end
