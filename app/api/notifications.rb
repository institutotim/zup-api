module Notifications
  class API < Base::API
    resources :notifications do
      desc 'List all notifications of current user'
      paginate per_page: 10
      get do
        authenticate!

        notifications = current_user.notifications

        {
          unread_count: notifications.unread.count,
          notifications: ::Notification::Entity.represent(paginate(notifications), only: return_fields)
        }
      end

      desc 'Mark all notifications as read'
      put 'read-all' do
        authenticate!

        current_user.notifications.read_all!

        {
          message: I18n.t(:'api.notifications.read_all.success')
        }
      end

      desc 'Delete a notification'
      delete ':id' do
        authenticate!

        Notification.find(safe_params[:id]).destroy!

        {
          message: I18n.t(:'api.notifications.delete.success')
        }
      end
    end
  end
end
