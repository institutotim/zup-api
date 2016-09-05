class Trigger < ActiveRecord::Base
  serialize :action_values
  has_paper_trail only: :just_with_build!, on: :update

  ACTION_TYPES = %w{enable_steps disable_steps finish_flow transfer_flow}

  belongs_to :user
  belongs_to :step
  has_many :trigger_conditions, dependent: :destroy

  accepts_nested_attributes_for :trigger_conditions

  default_scope -> { order(id: :asc) }
  scope :active, -> { where(active: true) }

  validates :title, length: { maximum: 100 }, presence: true
  validates :action_values, :trigger_conditions, presence: true
  validates :action_type, inclusion: { in: ACTION_TYPES }, presence: true

  after_create :add_trigger_on_step
  before_update :set_draft, unless: :draft_changed?
  before_update :remove_trigger_on_step, if: -> { active_changed? && !active }
  before_destroy :remove_trigger_on_step

  def self.update_order!(ids, _user = nil)
    step      = find(ids.first).step
    triggers  = step.triggers_versions
    order_ids = ids.inject({}) do |ids, id|
      ids[id.to_s] = triggers[id.to_s]
      ids
    end
    step.update!(triggers_versions: {})
    step.update!(triggers_versions: order_ids)
  end

  def inactive!
    versions.present? ? update!(active: false) : destroy!
  end

  def my_trigger_conditions(options = {})
    return trigger_conditions.where(options) if trigger_conditions_versions.blank?
    Version.where('TriggerCondition', trigger_conditions_versions, options)
  end

  def get_flow(object = nil)
    @get_flow ||= object || step.flow
  end

  private

  def add_trigger_on_step
    trigger_versions = step.triggers_versions.dup
    trigger_versions.merge!(id.to_s => nil)
    step.update!(user: user, triggers_versions: {})
    step.update!(user: user, triggers_versions: trigger_versions)
  end

  def set_draft
    get_flow.update! updated_by: user, draft: true
    self.draft = true
  end

  def remove_trigger_on_step
    trigger_versions = step.triggers_versions.dup
    trigger_versions.delete(id.to_s)
    step.update!(user: user, triggers_versions: {})
    step.update!(user: user, triggers_versions: trigger_versions)
  end

  # used on Entity
  def list_versions
    versions.map(&:reify) if versions.present?
  end

  def version_id
    version.try(:id)
  end

  class EntityVersion < Grape::Entity
    expose :id
    expose :title
    expose :description
    expose :trigger_conditions,    using: TriggerCondition::Entity
    expose :my_trigger_conditions, using: TriggerCondition::Entity
    expose :action_type
    expose :action_values
    expose :active
    expose :version_id
    expose :updated_at
    expose :created_at
  end

  class Entity < Grape::Entity
    expose :id
    expose :title
    expose :description
    expose :trigger_conditions,    using: TriggerCondition::Entity
    expose :my_trigger_conditions, using: TriggerCondition::Entity
    expose :action_type
    expose :action_values
    expose :active
    expose :version_id
    expose :updated_at
    expose :created_at
    expose :list_versions, using: Trigger::EntityVersion
  end
end
