module Reports
  module Notifications
    class API < Grape::API
      helpers do
        def load_item(item_id = params[:item_id])
          Reports::Item.find(item_id)
        end

        def load_category(category_id = params[:category_id])
          Reports::Category.find(category_id)
        end

        def load_notification(notification_id = params[:id])
          Reports::Notification.find(notification_id)
        end
      end

      namespace 'categories/:category_id/items/:item_id/notifications' do
        desc 'Shows all notifications available for the report'
        get do
          authenticate!
          item = load_item
          validate_permission!(:view, item)

          notifications_for_item = Reports::ListNotificationsForItem.new(
            item, only: return_fields
          ).fetch

          { notifications: notifications_for_item }
        end

        desc 'Creates (send) a notification for the report item'
        params do
          requires :notification_type_id, type: Integer
          optional :deadline_in_days, type: Integer
        end
        post do
          authenticate!
          item = load_item
          validate_permission!(:send_notification, item)

          category = load_category
          notification_type = category.notification_types.find(params[:notification_type_id])

          notification_manager = Reports::NotificationSendingManager.new(item, current_user)

          if notification_manager.can_send_notification?(notification_type)
            notification = notification_manager.create!(
              notification_type: notification_type,
              deadline_in_days: params[:deadline_in_days]
            )

            {
              notification: Reports::Notification::Entity.represent(notification, only: return_fields)
            }
          else
            status 400
            {
              error: 'model_validation',
              message: I18n.t(:'reports.notifications.create.error')
            }
          end
        end

        desc 'Shows notifications history for the report item'
        get 'history' do
          authenticate!
          item = load_item
          validate_permission!(:view, item)

          notifications = item.notifications

          { notifications: Reports::Notification::Entity.represent(notifications, only: return_fields) }
        end

        desc 'Restarts the notification process for the report item'
        put 'restart' do
          authenticate!
          item = load_item
          validate_permission!(:restart_notification, item)

          Reports::NotificationSendingManager.new(item, current_user).restart!

          {
            message: I18n.t(:'reports.notifications.restart.success'),
            current_status: Reports::StatusCategory::Entity.represent(item.try(:status_for_user))
          }
        end

        desc 'Returns last notification for item'
        get 'last' do
          authenticate!
          item = load_item
          validate_permission!(:view, item)

          notification = Reports::Notification.last_notification_for(item)

          {
            notification: Reports::Notification::Entity.represent(notification, only: return_fields)
          }
        end

        desc 'Returns a specific notification'
        get ':id' do
          authenticate!
          item = load_item
          validate_permission!(:view, item)

          notification = Reports::Notification.find(params[:id])

          {
            notification: Reports::Notification::Entity.represent(notification, only: return_fields)
          }
        end

        desc 'Re-send a notification'
        put ':id/resend' do
          authenticate!
          item = load_item
          validate_permission!(:restart_notification, item)

          notification = load_notification

          notification_manager = Reports::NotificationSendingManager.new(item, current_user)

          if notification_manager.can_send_notification?(notification)
            notification = notification_manager.resend!(notification)

            {
              notification: Reports::Notification::Entity.represent(notification, only: return_fields)
            }
          else
            status 400
            {
              error: 'model_validation',
              message: I18n.t(:'reports.notifications.resend.error')
            }
          end
        end
      end
    end
  end
end
