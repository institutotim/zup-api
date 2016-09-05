class CasesLogEntry < ActiveRecord::Base
  belongs_to :user
  belongs_to :flow
  belongs_to :step
  belongs_to :case
  belongs_to :new_flow,     class_name: 'Flow',  foreign_key: :new_flow_id
  belongs_to :before_user,  class_name: 'User',  foreign_key: :before_user_id
  belongs_to :after_user,   class_name: 'User',  foreign_key: :after_user_id
  belongs_to :before_group, class_name: 'Group', foreign_key: :before_group_id
  belongs_to :after_group,  class_name: 'Group', foreign_key: :after_group_id
  belongs_to :child_case,   class_name: 'Case',  foreign_key: :child_case_id

  ACTION_TYPES = %w{create_case next_step update_step removed_case_step finished transfer_case
                    transfer_flow delete_case restored_case started_step not_satisfied}

  # TODO: shouldn't it have more validations? At least presence ones
  validates :action, inclusion: { in: ACTION_TYPES }, presence: true

  class Entity < Grape::Entity
    expose :id
    expose :user_id
    expose :new_flow_id
    expose :flow_id
    expose :flow_version
    expose :step_id
    expose :case_id
    expose :child_case_id
    expose :before_group_id
    expose :after_group_id
    expose :before_user_id
    expose :after_user_id
    expose :action
    expose :created_at
    expose :updated_at
    with_options(if: { display_type: 'full' }) do
      expose :user,         using: User::Entity
      expose :new_flow,     using: Flow::Entity
      expose :flow,         using: Flow::Entity
      expose :step,         using: Step::Entity
      expose :case,         using: Case::Entity
      expose :child_case,   using: Case::Entity
      expose :before_group, using: Group::Entity
      expose :after_group,  using: Group::Entity
      expose :before_user,  using: User::Entity
      expose :after_user,   using: User::Entity
    end
  end
end
