class Case < ActiveRecord::Base
  include PgSearch
  include NamespaceFilterable

  scope :active,       -> { where(status: %w{active pending transfer not_satisfied}) }
  scope :not_inactive, -> { where.not(status: 'inactive') }
  scope :inactive,     -> { where(status: 'inactive') }

  pg_search_scope :search, against: [:status], associated_against: {
    initial_flow: :title,
    steps: :title,
    resolution_state: :title
  }

  belongs_to :created_by,    class_name: 'User', foreign_key: :created_by_id
  belongs_to :initial_flow,  class_name: 'Flow', foreign_key: :initial_flow_id
  belongs_to :namespace
  belongs_to :original_case, class_name: 'Case', foreign_key: :original_case_id

  belongs_to :resolution_state,
    class_name: 'ResolutionState',
    foreign_key: :resolution_state_id

  belongs_to :source_reports_category,
    class_name: 'Reports::Category',
    foreign_key: :source_reports_category_id

  belongs_to :updated_by, class_name: 'User', foreign_key: :updated_by_id

  has_many :case_steps, autosave: true, dependent: :destroy
  has_many :cases_log_entries, dependent: :destroy

  has_many :cases_log_entries_as_child_case,
    class_name: 'CasesLogEntry',
    foreign_key: :child_case_id

  has_many :chat_messages, as: :chattable, dependent: :destroy
  has_many :children_cases, class_name: 'Case', foreign_key: :original_case_id
  # TODO: define "dependent" for each association
  has_many :steps, through: :case_steps

  accepts_nested_attributes_for :case_steps

  validates :created_by_id, :initial_flow_id, :namespace_id, presence: true
  validates :status, inclusion: { in: %w{active pending finished inactive transfer not_satisfied} } # TODO: use enum?
  validate :not_change_initial_flow, on: :update

  def log!(action, options = {})
    basic = { flow: initial_flow, flow_version: flow_version, user: created_by,
             step: case_steps.last.try(:my_step), action: action }
    cases_log_entries.create! basic.merge(options)
  end

  def responsible_user_id
    get_responsible_user.try(:id)
  end

  def responsible_group_id
    get_responsible_group.try(:id)
  end

  def next_step
    actual_step = case_steps.try(:last)
    return actual_step.step if actual_step.present? && actual_step.case_step_data_fields.blank?
    my_initial_flow.get_new_step_to_case(actual_step.try(:my_step), disabled_steps)
  end

  def steps_not_fulfilled
    my_initial_flow.list_all_steps(my_initial_flow, disabled_steps).reject do |step|
      step.my_case_steps(case_id: id).first.try(:executed?)
    end.map(&:id)
  end

  def my_initial_flow
    Version.reify(flow_version)
  end

  def related_entities
    Cases::RelatedEntities.new(self)
  end

  private

  def not_change_initial_flow
    initial_flow_id_changed? && errors.add(:initial_flow, :changed)
  end

  def total_steps
    initial_flow.list_all_steps.size
  end

  def next_step_id
    next_step.try(:id)
  end

  def children_case_id
    children_cases.pluck(:id).first
  end

  def get_responsible_user
    case_steps.last.try(:responsible_user) || (responsible_user && User.find(responsible_user))
  end

  def get_responsible_group
    case_steps.last.try(:responsible_group) || (responsible_group && Group.find(responsible_group))
  end

  class Entity < Grape::Entity
    include GrapeEntityHelper

    def previous_steps(instance, options = {})
      case_step_ids = []
      case_steps    = instance.case_steps.reject{ |cs| cs.id == instance.case_steps.last.id }
      if options[:just_user_can_view]
        @permissions ||= UserAbility.for_user(options[:current_user])
        case_steps = case_steps.map do |case_step|
          case_step unless @permissions.can?(:show, case_step.step)
        end.compact if instance.case_steps.count > 1
        case_step_ids = case_steps.map(&:id) if case_steps.present?
      end
      options = extract_options_for(:previous_steps)

      CaseStep::Entity.represent case_steps, options.merge(simplify_to: case_step_ids)
    end

    def case_step_ids(instance, options)
      case_step_ids = instance.case_steps.map(&:id)
      if options[:just_user_can_view]
        @permissions ||= UserAbility.for_user(options[:current_user])
        case_steps = instance.case_steps.map do |case_step|
          case_step_ids -= [case_step.id] unless @permissions.can?(:show, case_step.step)
        end.compact if instance.case_steps.any?
      end
      case_step_ids
    end

    def case_steps(instance, options)
      case_step_ids = []

      if options[:just_user_can_view]
        @permissions ||= UserAbility.for_user(options[:current_user])
        case_steps = instance.case_steps.map do |case_step|
          case_step unless @permissions.can?(:show, case_step.step)
        end.compact if instance.case_steps.any?
        case_step_ids = case_steps.map(&:id) if case_steps.present?
      end
      options = extract_options_for(:case_steps)

      CaseStep::Entity.represent(instance.case_steps, options.merge(simplify_to: case_step_ids))
    end

    def current_step(instance, options = {})
      case_step = instance.case_steps.last

      if options[:just_user_can_view] && case_step.present?
        @permissions ||= UserAbility.for_user(options[:current_user])
        case_step_ids = case_step.id unless @permissions.can?(:show, case_step.step)
      end

      options = extract_options_for(:current_step)

      CaseStep::Entity.represent(case_step, options.merge(simplify_to: case_step_ids))
    end

    def next_steps(instance, options = {})
      old_steps   = instance.case_steps.present? ? instance.case_steps.map { |cs| cs.step.id } : []
      skip_steps  = old_steps + instance.disabled_steps
      steps       = instance.my_initial_flow.list_all_steps(instance.my_initial_flow, skip_steps)
      options = extract_options_for(:next_steps)

      Step::Entity.represent(steps, options)
    end

    def list_tree_steps(instance, _options = {})
      instance.my_initial_flow.list_tree_steps(instance.my_initial_flow)
    end

    def change_options_to_return_fields(key, _options = {})
      extract_options_for(key)
    end

    expose :id
    expose :created_by_id
    expose :updated_by_id
    expose :created_at
    expose :updated_at
    expose :initial_flow_id
    expose :initial_flow, using: Flow::Entity
    expose :flow_version
    expose :total_steps
    expose :disabled_steps
    expose :original_case_id
    expose :children_case_id
    expose :case_step_ids do |instance, options|
      case_step_ids(instance, change_options_to_return_fields(:case_step_ids, options))
    end
    expose :next_step_id
    expose :responsible_user_id
    expose :responsible_group_id
    expose :status
    expose :resolution_state, using: ResolutionState::Entity
    expose :steps_not_fulfilled
    expose :related_entities, using: Cases::RelatedEntities::Entity
    expose :completed do |instance, _options|
      instance.status == 'finished'
    end
    expose :created_by,            using: User::Entity
    expose :updated_by,            using: User::Entity
    expose :get_responsible_user,  using: User::Entity
    expose :get_responsible_group, using: Group::Entity
    expose :original_case,         using: Case::Entity
    expose :case_steps do |instance, options|
      case_steps(instance, change_options_to_return_fields(:case_steps, options))
    end
    expose :current_step do |instance, options|
      current_step(instance, change_options_to_return_fields(:current_step, options))
    end
    expose :steps do |instance, options|
      list_tree_steps(instance, change_options_to_return_fields(:steps, options))
    end
    expose :next_steps do |instance, options|
      next_steps(instance, change_options_to_return_fields(:steps, options))
    end
    expose :previous_steps do |instance, options|
      previous_steps(instance, change_options_to_return_fields(:steps, options))
    end
  end
end
