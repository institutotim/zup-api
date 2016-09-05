module Reports
  class NotificationSendingManager
    attr_reader :item, :category, :user, :setting

    def initialize(item, user = nil)
      @item = item
      @user = user
      @category = item.category
      @setting = item.setting
    end

    # Creates a notification for the report item
    #
    # What envolve creating/sending a notification?
    #
    #   1. Creates a notification for the type and item
    #   2. Sets the adequate `overdue_at` for the notification
    #   3. Saves the current status id to `previous_status_id`
    #   4. Change the item status (if applyable)
    #   5. Creates a history entry
    #
    def create!(params)
      params = params.merge(
        user: user,
        item: item
      )

      notification = build_notification_for_type(params)
      notification.save!

      update_item_status_from_notification!(notification)
      create_send_history_entry(notification, user)

      notification
    end

    # Resends a notification
    def resend!(notification)
      notification.inactive!

      create!(
        notification_type: notification.notification_type
      )
    end

    # Restart the notification process
    #
    #   1. Set the item status to the first one
    #   2. Mark all notifications as inactive
    #   3. Create history entry
    #
    def restart!
      status = first_notification_status_change_for_item

      update_item_status!(status) if status
      Reports::Notification.for_item(item).inactive_all!
      create_restart_history_entry(user)
    end

    # @param notification Can be NotificationType or a Notification
    def can_send_notification?(notification)
      # If the category demands the notification to be sent in order, let's check
      # if the order is correct
      if notification.is_a?(NotificationType)
        if setting.ordered_notifications?
          notification_type_is_next?(notification)
        else
          true
        end
      elsif notification.is_a?(Notification) && notification.able_to_send?
        true
      else
        false
      end
    end

    def first_notification_status_change_for_item
      if setting.ordered_notifications?
        notification = Reports::Notification.with_status_change.ordered.for_item(item).first
      else
        notification = Reports::Notification.with_status_change.ordered_by_creation.for_item(item).first
      end

      notification.previous_status if notification
    end

    private

    def notification_type_is_next?(notification_type)
      # If it's the first notification type, we can send it
      return true if notification_type.order == 0

      notification_types = Reports::NotificationType.for_category(category, item.namespace_id).ordered
      previous_type = notification_types[notification_type.order - 1]

      previous_type.sent_for_item?(item)
    end

    def build_notification_for_type(params)
      notification = Reports::Notification.new(params)
      notification.send(:set_deadline_in_days)

      if notification.deadline_in_days && !notification.deadline_in_days.zero?
        notification.overdue_at = Time.now + notification.deadline_in_days.days
      end

      notification.previous_status = item.status
      notification
    end

    def update_item_status_from_notification!(notification)
      notification_type = notification.notification_type

      if notification_type.status.present?
        Reports::Item.transaction do
          notification.update!(previous_status: item.status)
          update_item_status!(notification_type.status)
        end
      end
    end

    def update_item_status!(status)
      Reports::UpdateItemStatus.new(item, user).update_status!(status)
    end

    def create_send_history_entry(notification, user)
      Reports::CreateHistoryEntry.new(item, user).create(
        'notification', 'Enviou uma notificação', new: {
          title: notification.notification_type.title
        }
      )
    end

    def create_restart_history_entry(user)
      Reports::CreateHistoryEntry.new(item, user).create(
        'notification_restart', 'Reiniciou o processo de notificação'
      )
    end
  end
end
