class Flow < ActiveRecord::Base
  include PgSearch
  attr_accessor :user
  has_paper_trail only: :just_with_build!, on: :update

  PERMISSION_TYPES = %w{flow_can_view_all_steps flow_can_execute_all_steps
                        flow_can_delete_own_cases flow_can_delete_all_cases}

  belongs_to :created_by,      class_name: 'User', foreign_key: :created_by_id
  belongs_to :updated_by,      class_name: 'User', foreign_key: :updated_by_id
  has_many :cases,             class_name: 'Case', foreign_key: :initial_flow_id
  has_many :parent_steps,      class_name: 'Step', foreign_key: :child_flow_id
  has_many :steps,             dependent: :destroy
  has_many :fields,            through: :steps
  has_many :resolution_states, dependent: :destroy
  has_many :cases_log_entries
  has_many :cases_log_entries_as_new_flow, class_name: 'CasesLogEntry', foreign_key: :new_flow_id

  scope :active, -> { where.not(status: :inactive) }

  pg_search_scope :search,
    against: [:title, :status],
    associated_against: {
      steps: :title,
      resolution_states: :title
    },
    using: {
      tsearch: { prefix: true }
    }

  validates :title, :created_by, presence: true
  validates :title, length: { maximum: 100 }
  validates :description, length: { maximum: 600 }
  validates :updated_by, presence: true, on: :update
  validates :status, inclusion: %w(active pending inactive)

  after_validation :verify_if_has_resolution_state_default, if: -> { status != 'inactive' }
  before_update :set_draft, unless: -> { self.draft_changed? || self.current_version_changed? }

  def self.find_initial(id)
    find_by(initial: true, id: id)
  end

  # This method publishes the flow
  #
  # What does 'publish' mean?
  #
  # Once a flow is edited by the user, it's marked as a draf, thus a user can publish it.
  # By publishing it, a series of steps are taken:
  #
  # 1. Build new versions for resolution states, or override if no case are using it
  # 2. Build new versions for steps which are changed, or override the latest version if no case are using
  #    this flow yet
  # 3. Same of step 2 for triggers, fields and the flow itself
  # 4. The flow is unmarked as `draft`
  def publish(current_user)
    user = current_user
    return if user.blank? || !draft

    transaction do
      override_old_version = versions.present? && Version.reify_last_version(self).cases_arent_using?
      resolutions_versions = resolution_states_versions.dup
      step_versions        = steps_versions.dup

      my_resolution_states(draft: true).each do |resolution|
        resolution.update!(user: user, draft: false)
        Version.build!(resolution, override_old_version)
        resolutions_versions[resolution.id.to_s] = resolution.versions.last.id
      end

      my_steps(draft: true).each do |step|
        trigger_versions = step.triggers_versions.dup
        field_versions   = step.fields_versions.dup

        step.my_triggers(draft: true).each do |trigger|
          condition_versions = trigger.trigger_conditions_versions.dup

          trigger.my_trigger_conditions(draft: true).each do |condition|
            condition.update!(user: user, draft: false)
            Version.build!(condition, override_old_version)
            condition_versions[condition.id.to_s] = condition.versions.last.id
          end

          trigger.update!(user: user, draft: false,
                          trigger_conditions_versions: condition_versions)
          Version.build!(trigger, override_old_version)
          trigger_versions[trigger.id.to_s] = trigger.versions.last.id
        end

        step.my_fields(draft: true).each do |field|
          field.update!(user: user, draft: false)
          Version.build!(field, override_old_version)
          field_versions[field.id.to_s] = field.versions.last.id
        end

        step.update!(
          triggers_versions: trigger_versions,
          fields_versions: field_versions,
          user: user,
          draft: false
        )

        Version.build!(step, override_old_version)
        step_versions[step.id.to_s] = step.versions.last.id
      end

      update!(
        resolution_states_versions: resolutions_versions,
        steps_versions: step_versions,
        draft: false,
        current_version: nil,
        updated_by: user
      )

      Version.build!(self, override_old_version)
    end
  end

  def update_resolution_states(resolution_states)
    current_rs_ids = self.resolution_states.pluck(:id) # ids of the existing resolution states for this flow

    transaction do
      # If creating or updating the default state, change the old one to false
      new_default_rs = resolution_states.select { |rs| rs['default'] }
      fail(ActiveRecord::RecordInvalid.new(self)) if new_default_rs.count > 1

      if new_default_rs.any?
        new_default_rs = new_default_rs.first
        current_default = self.resolution_states.where(default: true).first
        current_default.update_attribute(:default, false) if current_default && current_default.id != new_default_rs['id']
      end

      # Add new resolution states
      resolution_states.select { |rs| !rs['id'] }
          .each { |rs| self.resolution_states.create!(rs.merge!(flow_id: id)) }

      # Update existing resolution states
      resolution_states.select { |rs| rs['id'] } # items with an id field are meant to be updated
          .select { |rs| current_rs_ids.include?(rs['id'].to_i) } # so they must exist in the current_rs_ids
          .each { |rs| self.resolution_states.find(rs['id']).update!(rs) }

      # Prune old resolution states
      new_rs_ids = resolution_states.map { |rs| rs['id'] } # ids of the new resolution state set
      rs_ids_to_remove = current_rs_ids.select { |rs_id| !new_rs_ids.include?(rs_id) } # if not present they must be removed
      self.resolution_states.where(id: rs_ids_to_remove).update_all(active: false)
    end

    nil
  end

  def cases_arent_using?
    not (my_cases.present? || my_steps(step_type: 'form').map(&:my_case_steps).flatten.present?)
  end

  def inactive!
    versions.present? ? update!(updated_by: user, status: 'inactive') : destroy!
  end

  def my_cases(options = {})
    return [] if versions.blank?
    my_version = version || versions.last.try(:id)
    cases.where(options.merge(flow_version: my_version))
  end

  def my_steps(options = {})
    return steps.where(options) if steps_versions.blank? || draft
    Version.where('Step', steps_versions, options)
  end

  def my_resolution_states(options = {})
    return resolution_states.where(options) if resolution_states_versions.blank?
    Version.where('ResolutionState', resolution_states_versions, options)
  end

  def the_version(param_draft = false, version_id = nil)
    return Version.reify(version_id) if version_id.present?
    return self if (param_draft && draft) || versions.blank?
    current_version.present? ? Version.reify(current_version) : previous_version
  end

  # revisar regra de versao
  def ancestors(child_flow = self)
    parents = []
    parents << child_flow
    parents << child_flow.parent_steps.map { |s| ancestors(s.flow) } if child_flow.parent_steps.present?
    parents.flatten.uniq
  end

  # revisar regra de versao
  def list_tree_steps(flow_step = self, skips = [])
    steps_children = []

    if flow_step.present? && flow_step.my_steps.present?
      flow_step.my_steps.reject { |s| skips.include?(s.id) }.each do |step|
        steps_children << {
          step: Step::Entity.represent(step, display_type: 'full'),
          flow: Flow::Entity.represent(step.my_child_flow, display_type: 'full'),
          steps: Step::Entity.represent((step.step_type == 'flow' ? list_tree_steps(step.my_child_flow, skips) : []), display_type: 'full')
        }
      end
    end

    steps_children
  end

  def list_all_steps(flow_step = self, skips = [])
    return @list_all_steps if @list_all_steps.present? && skips.blank?
    steps_children = []
    return steps_children if flow_step.try(:my_steps).blank?

    flow_step.my_steps.reject{ |step| skips.include? step.id }.each do |step|
      steps = step.step_type == 'flow' ? list_all_steps(step.my_child_flow, skips) : step
      steps_children.push(steps)
    end

    @list_all_steps = steps_children.flatten
  end

  def find_step_on_list(step_id)
    list_all_steps.select do |step|
      step.id == step_id.to_i
    end.first
  end

  def get_new_step_to_case(actual_step = nil, skips = [])
    all_steps = list_all_steps(self, skips)
    return all_steps.first if actual_step.blank? || all_steps.blank?
    next_step_index = all_steps.index(actual_step).try(:next)
    next_step_index && all_steps[next_step_index]
  end

  # verificar se algum lugar usa
  def find_my_step_form_on_tree(flow = self, step_id)
    found_step = nil
    flow.my_steps.each do |step|
      found_step = step if step.id == step_id.to_i
      found_step = find_my_step_form_on_tree(step.my_child_flow, step_id) if step.step_type == 'flow'
      return found_step if found_step.present?
    end
    found_step if found_step.present?
  end

  private

  def verify_if_has_resolution_state_default
    new_status  = 'pending'
    new_status  = 'active'   if persisted? && resolution_states.find_by(default: true).present?
    self.status = new_status if status != new_status
  end

  def set_draft
    self.draft = true
  end

  # used on Entity
  def list_versions
    versions.map(&:reify) if versions.present?
  end

  def total_cases
    cases_id      = my_cases.present? ? my_cases.map(&:id) : []
    step          = my_steps(step_type: 'form').first
    step_cases_id = step.present? && step.my_case_steps.present? ?
                      step.my_case_steps.map(&:case_id) : []
    (cases_id + step_cases_id).uniq.size
  end

  def steps_id
    steps_versions.to_h.keys
  end

  def permissions
    PERMISSION_TYPES.inject({}) do |permissions, permission|
      permissions[permission] = Group::Entity.represent(Group.that_includes_permission(permission, id))
      permissions
    end
  end

  def my_steps_flows
    my_steps.map do |step|
      if step.step_type == 'form'
        step
      else
        if step.my_child_flow.present?
          child_flow = step.my_child_flow.attributes.merge(my_steps: step.my_child_flow.my_steps)
        else
          child_flow = nil
        end
        step.attributes.merge(my_child_flow: child_flow)
      end
    end
  end

  def version_id
    version.try(:id)
  end

  class EntityVersion < Grape::Entity
    expose :id
    expose :title
    expose :description
    expose :initial
    expose :steps,                using: Step::Entity, if: { display_type: 'full' }
    expose :my_steps,             using: Step::Entity, if: { display_type: 'full' }
    expose :my_steps_flows,       if: { display_type: 'full' }
    expose :steps_versions
    expose :steps_order
    expose :steps_id,             unless: { display_type: 'full' }
    expose :resolution_states,    using: ResolutionState::Entity
    expose :my_resolution_states, using: ResolutionState::Entity
    expose :resolution_states_versions
    expose :status
    expose :draft
    expose :total_cases
    expose :version_id
    expose :permissions,          if: { display_type: 'full' }
    expose :created_by_id,        unless: { display_type: 'full' }
    expose :updated_by_id,        unless: { display_type: 'full' }
    expose :created_by,           using: User::Entity, if: { display_type: 'full' }
    expose :updated_by,           using: User::Entity, if: { display_type: 'full' }
    expose :updated_at
    expose :created_at
  end

  class Entity < Grape::Entity
    expose :id
    expose :title
    expose :description
    expose :initial
    expose :steps,                using: Step::Entity, if: { display_type: 'full' }
    expose :my_steps,             using: Step::Entity, if: { display_type: 'full' }
    expose :my_steps_flows,       if: { display_type: 'full' }
    expose :steps_versions
    expose :steps_order
    expose :steps_id,             unless: { display_type: 'full' }
    expose :resolution_states,    using: ResolutionState::Entity
    expose :my_resolution_states, using: ResolutionState::Entity
    expose :status
    expose :draft
    expose :total_cases
    expose :version_id
    expose :permissions,          if:     { display_type: 'full' }
    expose :created_by_id,        unless: { display_type: 'full' }
    expose :updated_by_id,        unless: { display_type: 'full' }
    expose :created_by,           using: User::Entity, if: { display_type: 'full' }
    expose :updated_by,           using: User::Entity, if: { display_type: 'full' }
    expose :updated_at
    expose :created_at
  end
end
