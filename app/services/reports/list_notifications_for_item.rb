module Reports
  class ListNotificationsForItem
    attr_reader :item, :params, :notification_manager

    def initialize(item, params = {})
      @item = item
      @params = params
      @notification_manager = Reports::NotificationSendingManager.new(item)
    end

    # For each notification type for the category
    # it should return a record.
    #
    # If it already have a notification for that type,
    # shows info about it instead.
    def fetch
      notification_types = Reports::NotificationType.for_category(item.category, item.namespace_id)

      entities = []
      notification_types.each do |notification_type|
        # Does item already have notification for this type?
        notification = Reports::Notification.last_notification_for(item, notification_type)

        if notification
          entities << add_entity_from_notification(notification)
        else
          entities << add_entity_from_notification_type(notification_type)
        end
      end

      entities
    end

    private

    def add_entity_from_notification(notification)
      entity = notification.entity(only: params[:return_fields]).serializable_hash

      entity[:id] = notification.id
      entity[:kind] = 'notification'
      entity[:sent] = true
      entity[:able_to_send] = notification_manager.can_send_notification?(notification)
      entity[:days_to_deadline] = notification.days_to_deadline

      entity
    end

    def add_entity_from_notification_type(notification_type)
      example_notification = Reports::Notification.new(
        item: item,
        notification_type: notification_type
      )

      entity = example_notification.entity(only: params[:return_fields]).serializable_hash

      entity[:id] = notification_type.id
      entity[:kind] = 'notification_type'
      entity[:sent] = false
      entity[:able_to_send] = notification_manager.can_send_notification?(notification_type)
      entity[:days_to_deadline] = nil

      entity
    end
  end
end
