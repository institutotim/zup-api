module Reports
  class Notification < Reports::Base
    belongs_to :item, class_name: 'Reports::Item',
                      foreign_key: 'reports_item_id'
    belongs_to :user
    belongs_to :previous_status, class_name: 'Reports::Status'
    belongs_to :notification_type, class_name: 'Reports::NotificationType',
                                   foreign_key: 'reports_notification_type_id'
    has_one :category, through: :item

    validates :item, presence: true
    validates :user, presence: true
    validates :notification_type, presence: true

    scope :active, -> { where(active: true) }
    scope :for_item, -> (item) { where(reports_item_id: item.id) }
    scope :for_type, -> (notification_type) { where(reports_notification_type_id: notification_type.id) }
    scope :ordered, -> {
      joins(:notification_type).order('reports_notification_types.order ASC')
    }
    scope :with_status_change, -> { where.not(previous_status_id: nil) }
    scope :ordered_by_creation, -> { order(created_at: :asc) }

    before_validation :set_deadline_in_days
    before_create :set_content

    def self.last_notification_for(item, notification_type = nil)
      scope = for_item(item).active

      if notification_type
        scope = scope.for_type(notification_type)
      end

      scope.order(id: :desc).first
    end

    def self.inactive_all!
      active.update_all(active: false)
    end

    def days_to_deadline
      if overdue_at
        (overdue_at.to_date - Time.now.to_date).to_i
      end
    end

    def able_to_send?
      if overdue_at
        Time.now < overdue_at
      else
        true
      end
    end

    def inactive!
      update!(active: false)
    end

    def current?
      id == self.class.last_notification_for(item).try(:id)
    end

    class Entity < Grape::Entity
      expose :id
      expose :user, using: User::Entity
      expose :previous_status, using: Reports::StatusCategory::Entity
      expose :current_status, using: Reports::StatusCategory::Entity
      expose :notification_type, using: Reports::NotificationType::Entity
      expose :deadline_in_days
      expose :days_to_deadline
      expose :content
      expose :created_at
      expose :updated_at
      expose :overdue_at
      expose :active
      expose :current

      def current
        object.current?
      end

      def previous_status
        if object.previous_status
          object.previous_status.for_category(object.category, object.item.namespace_id)
        end
      end

      def current_status
        object.try(:item).try(:status_for_user)
      end
    end

    class SearchReportEntity < Entity
      expose :item, using: 'Reports::Item::ListingEntity'
      expose :category, using: Reports::Category::Entity
    end

    private

    def set_deadline_in_days
      self.deadline_in_days = notification_type.default_deadline_in_days if deadline_in_days.blank?
    end

    def set_content
      layout_parser = Reports::NotificationLayoutParser.new(self)
      self.content = layout_parser.parsed_html
    end
  end
end
