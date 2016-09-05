class Reports::ItemStatusHistory < Reports::Base
  belongs_to :item, class_name: 'Reports::Item', foreign_key: 'reports_item_id'
  belongs_to :previous_status, class_name: 'Reports::Status', foreign_key: 'previous_status_id'
  belongs_to :new_status, class_name: 'Reports::Status', foreign_key: 'new_status_id'

  validates :item, presence: true
  validates :new_status, presence: true

  default_scope { order('id ASC') }
  scope :all_public, -> { joins(:new_status).where(new_status: { private: false }) }

  def previous_status_for_category
    previous_status.for_category(item.category, item.namespace_id) if previous_status
  end

  def new_status_for_category
    new_status.for_category(item.category, item.namespace_id) if new_status
  end

  class Entity < Grape::Entity
    expose :id
    expose :previous_status_for_category, as: :previous_status, using: Reports::StatusCategory::Entity
    expose :new_status_for_category, as: :new_status, using: Reports::StatusCategory::Entity
    expose :created_at
    expose :updated_at
  end
end
