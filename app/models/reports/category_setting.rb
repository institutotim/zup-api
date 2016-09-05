class Reports::CategorySetting < Reports::Base
  include SolverGroup
  include NamespaceFilterable

  belongs_to :category,
    class_name: 'Reports::Category',
    foreign_key: :reports_category_id,
    touch: true

  belongs_to :namespace

  enum priority: [:low, :medium, :high]

  validates :reports_category_id, :namespace_id, presence: true
  validates :namespace_id, uniqueness: { scope: :reports_category_id }
  validates :confidential, inclusion: { in: [false, true] }
  validates :resolution_time, presence: true, if: :resolution_time_enabled?

  class Entity < Grape::Entity
    expose :id
    expose :resolution_time_enabled
    expose :resolution_time
    expose :private_resolution_time
    expose :user_response_time
    expose :allows_arbitrary_position
    expose :confidential
    expose :default_solver_group_id
    expose :solver_groups_ids
    expose :comment_required_when_forwarding
    expose :comment_required_when_updating_status
    expose :notifications
    expose :ordered_notifications
    expose :perimeters
    expose :flow_id
    expose :priority

    expose :category, using: Reports::Category::Entity
    expose :namespace, using: Namespace::Entity
  end
end
