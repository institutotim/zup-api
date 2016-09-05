class Step < ActiveRecord::Base
  has_paper_trail only: :just_with_build!, on: :update

  PERMISSION_TYPES = %w{can_view_step can_execute_step}

  belongs_to :user
  belongs_to :flow
  belongs_to :child_flow, class_name: 'Flow', foreign_key: :child_flow_id
  has_many :triggers,   dependent: :destroy
  has_many :fields,     dependent: :destroy
  has_many :case_steps
  has_many :cases_log_entries
  has_many :notifications, as: :notificable

  default_scope -> { where(active: true).order(id: :asc) }
  scope :active, -> { where(active: true) }

  validates :title, length: { maximum: 100 }, presence: true
  validates :step_type, presence: true
  validates :step_type, inclusion: %w(form flow), allow_blank: true
  validate :cant_use_parent_flow_on_child_flow, if: -> { step_type == 'flow' && child_flow.present? }

  after_create :add_step_on_flow
  before_update :set_draft, unless: :draft_changed?
  before_update :remove_step_on_flow, if: -> { active_changed? && !active }
  before_destroy :remove_step_on_flow

  def self.update_order!(steps_ids)
    flow      = find(steps_ids.first).flow
    steps     = flow.steps_versions

    order_ids = steps_ids.inject({}) do |ids, id|
      ids[id.to_s] = steps[id.to_s]
      ids
    end

    transaction do
      flow.update! steps_versions: {}
      flow.update!(steps_versions: order_ids)
      flow.update_attribute(:steps_order, steps_ids)
    end
  end

  def inactive!
    versions.present? ? update!(active: false) : destroy!
  end

  def my_case_steps(options = {})
    return [] if versions.blank?
    my_version = version || versions.last.try(:id)
    case_steps.where(options.merge(step_version: my_version))
  end

  def my_fields(options = {})
    return fields.where(options) if fields_versions.blank?
    Version.where('Field', fields_versions, options)
  end

  def my_triggers(options = {})
    return triggers.where(options) if triggers_versions.blank?
    Version.where('Trigger', triggers_versions, options)
  end

  def my_child_flow
    child_flow_version.blank? ? child_flow : Version.reify(child_flow_version)
  end

  def get_flow(object = nil)
    @get_flow ||= object || flow
  end

  def required_fields
    my_fields.select { |field| field.required? }
  end

  private

  def cant_use_parent_flow_on_child_flow
    return if get_flow.blank?
    errors.add(:child_flow, :invalid) if get_flow.ancestors.map(&:id).include? child_flow.id
  end

  def add_step_on_flow
    step_versions = get_flow.steps_versions.dup
    step_versions.merge!(id.to_s => nil)
    transaction do
      get_flow.update! updated_by: user, steps_versions: {}
      get_flow.update! updated_by: user, steps_versions: step_versions
      get_flow.update_attribute(:steps_order, get_flow.steps_order + [id])
    end
  end

  def set_draft
    get_flow.update! updated_by: user, draft: true
    self.draft = true
  end

  def remove_step_on_flow
    step_versions = get_flow.steps_versions.dup
    step_versions.delete(id.to_s)

    transaction do
      get_flow.update! updated_by: user, steps_versions: {}
      get_flow.update! updated_by: user, steps_versions: step_versions
      get_flow.update_attribute(:steps_order, get_flow.steps_order - [id])
    end

    true
  end

  # used on Entity
  def list_versions
    versions.map(&:reify) if versions.present?
  end

  def permissions
    PERMISSION_TYPES.inject({}) do |permissions, permission|
      permissions[permission] = Group::Entity.represent(Group.that_includes_permission(permission, id))
      permissions
    end
  end

  def fields_id
    versions.present? ? fields_versions.keys : fields.pluck(:id)
  end

  def child_flow_id
    child_flow.try(:id)
  end

  def version_id
    version.try(:id)
  end

  class EntityVersion < Grape::Entity
    expose :id
    expose :flow_id
    expose :title
    expose :conduction_mode_open
    expose :step_type
    expose :child_flow,    using: 'Flow::Entity'
    expose :my_child_flow, using: 'Flow::Entity'
    expose :child_flow_id
    expose :fields, using: 'Field::Entity' do |object, _|
      object.fields.active
    end
    expose :my_fields,     using: 'Field::Entity'
    expose :fields_id
    expose :active
    expose :version_id
    expose :permissions
    expose :updated_at
    expose :created_at
  end

  class Entity < Grape::Entity
    expose :id
    expose :flow_id
    expose :title
    expose :conduction_mode_open
    expose :step_type
    expose :child_flow,    using: 'Flow::Entity'
    expose :my_child_flow, using: 'Flow::Entity'
    expose :child_flow_id
    expose :fields,        using: 'Field::Entity'
    expose :my_fields,     using: 'Field::Entity'
    expose :triggers,      using: 'Trigger::Entity'
    expose :my_triggers,   using: 'Trigger::Entity'
    expose :fields_id
    expose :active
    expose :version_id
    expose :permissions
    expose :updated_at
    expose :created_at
  end
end
