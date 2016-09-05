class TriggerCondition < ActiveRecord::Base
  has_paper_trail only: :just_with_build!, on: :update
  serialize :values

  belongs_to :user
  belongs_to :trigger
  belongs_to :field

  scope :active, -> { where.not(status: :inactive) }

  validates :values,         presence: true
  validates :condition_type, inclusion: { in: %w{== != > < inc} }, presence: true

  after_create :add_condition_on_trigger
  before_update :set_draft, unless: :draft_changed?
  before_update :remove_condition_on_trigger, if: -> { active_changed? && !active }
  before_destroy :remove_condition_on_trigger

  def inactive!
    versions.present? ? update!(active: false) : destroy!
  end

  def my_field
    field_version.zero? ? field : Version.reify(field_version)
  end

  private

  def add_condition_on_trigger
    condition_versions = trigger.trigger_conditions_versions.dup
    condition_versions.merge!(id.to_s => nil)
    trigger.update! user: user, trigger_conditions_versions: {}
    trigger.update! user: user, trigger_conditions_versions: condition_versions
  end

  def set_draft
    get_flow.update! updated_by: user, draft: true
    self.draft = true
  end

  def remove_condition_on_trigger
    condition_versions = trigger.trigger_conditions_versions.dup
    condition_versions.delete(id.to_s)
    trigger.update! user: user, trigger_conditions_versions: {}
    trigger.update! user: user, trigger_conditions_versions: condition_versions
  end

  def get_flow(object = nil)
    @get_flow ||= object || trigger.step.flow
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
    expose :my_field, using: Field::Entity
    expose :condition_type
    expose :values
    expose :active
    expose :version_id
    expose :updated_at
    expose :created_at
  end

  class Entity < Grape::Entity
    expose :id
    expose :my_field, using: Field::Entity
    expose :condition_type
    expose :values
    expose :active
    expose :version_id
    expose :updated_at
    expose :created_at
    expose :list_versions, using: TriggerCondition::EntityVersion
  end
end
