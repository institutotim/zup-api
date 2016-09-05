class Reports::ItemHistory < Reports::Base
  include ArrayRelate

  KINDS = %w(attributes address description status category forward
             user_assign overdue comment creation notification
             notification_restart reference perimeter)

  belongs_to :item, class_name: 'Reports::Item', foreign_key: 'reports_item_id'
  belongs_to :user

  validates :kind, presence: true, inclusion: { in: KINDS }
  validates :action, presence: true
  validates :item, presence: true

  array_belongs_to :objects, polymorphic: 'object_type'

  class Entity < Grape::Entity
    expose :id
    expose :reports_item_id
    expose :user, using: User::Entity
    expose :kind
    expose :action
    expose :saved_changes, as: :changes
    expose :created_at
  end
end
