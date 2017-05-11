require 'digest/sha1'

class UserAbility
  include CanCan::Ability

  attr_reader :user, :permissions

  def self.for_user(user)
    user ||= User::Guest.new

    key = "#{(user.id || 0)}/#{Digest::SHA1.hexdigest(Group.cache_key)}"

    @abilities ||= {}

    unless @abilities[key]
      clear_invalid_cache
      @abilities[key] = new(user)
    end

    @abilities[key]
  end

  def self.clear_invalid_cache
    current_version_key = Group.cache_key
    @abilities.keys.each do |k|
      if k[-current_version_key.size..-1] != current_version_key
        @abilities.delete(k)
      end
    end
  end

  def self.clear_cache
    @abilities = {}
  end

  # TODO: Make this work with the Guest group.
  def initialize(given_user = nil)
    @user = (given_user || User::Guest.new)
    @permissions = user.permissions

    build_permissions
  end

  def inventory_categories_visible
    mount_ids_array_for(
      :inventories_categories_edit,
      :inventories_items_read_only,
      :inventories_items_edit,
      :inventories_items_create,
      :inventories_items_delete
    )
  end

  def inventory_sections_visible
    mount_ids_array_for(
      :inventory_sections_can_view,
      :inventory_sections_can_edit
    ) + sections_with_visible_fields
  end

  def sections_with_visible_fields
    Inventory::Field.where(id: inventory_fields_visible).pluck(:inventory_section_id).try(:uniq)
  end

  def reports_categories_visible
    mount_ids_array_for(
      :reports_items_read_public,
      :reports_items_read_private,
      :reports_items_edit,
      :reports_categories_edit,
      :reports_items_create,
      :reports_items_delete
    )
  end

  def reports_categories_creatable
    mount_ids_array_for(:reports_items_create, :reports_categories_edit)
  end

  def reports_categories_with_editable_items
    mount_ids_array_for(:reports_items_edit, :reports_categories_edit)
  end

  def reports_categories_visible_for_items
    mount_ids_array_for(
     :reports_items_read_public,
     :reports_items_read_private,
     :reports_items_edit,
     :reports_categories_edit,
     :reports_items_delete
    )
  end

  def chat_rooms_visible
    permissions.chat_rooms_read
  end

  def inventory_fields_visible
    mount_ids_array_for(:inventory_fields_can_view, :inventory_fields_can_edit)
  end

  def groups_visible
    mount_ids_array_for(:group_read_only, :group_edit, :users_edit)
  end

  def business_reports_visible
    permissions.business_reports_view
  end

  def cases_visible
    permissions.cases_with_reports_view
  end

  def namespaces_visible
    if permissions.manage_namespaces
      Namespace.all.pluck(:id)
    else
      namespaces_visible = permissions.namespaces_access
      namespaces_visible.push(user.namespace_id)
      namespaces_visible.compact.uniq
    end
  end

  private

  def mount_ids_array_for(*columns)
    ids = columns.inject([]) do |array, method|
      array.push(*Array(permissions.public_send(method)))
    end

    ids.uniq
  end

  def build_permissions
    painel_permissions
    groups_permissions
    users_permissions
    reports_permissions
    inventories_permissions
    flows_permissions
    cases_permissions
    business_reports_permissions
    chat_rooms_permissions
    namespaces_permissions
    services_permission
    event_logs_permissions
  end

  def painel_permissions
    if permissions.panel_access
      can :access, 'Panel'
    end

    if permissions.manage_config
      can :manage, FeatureFlag
    end

    if permissions.create_reports_from_panel
      can :create_from_panel, Reports::Item
    end
  end

  def services_permission
    if permissions.manage_services
      can :manage_services, User
    end
  end

  def groups_permissions
    if permissions.groups_full_access
      can :manage, Group
    end

    can [:edit, :view], Group do |group|
      permissions.group_edit.include?(group.id)
    end

    can :view, Group do |group|
      permissions.group_read_only.include?(group.id)
    end
  end

  def users_permissions
    if permissions.users_full_access
      can :manage, User
    end

    # User can edit your profile
    can :edit, User do |u|
      u.id == user.id
    end

    can [:view, :edit, :create, :delete], User do |u|
      (u.groups.map(&:id) & permissions.users_edit.to_a).any?
    end
  end

  def reports_permissions
    if permissions.reports_full_access
      can :manage, Reports::Category
      can :manage, Reports::Item
      can :manage, Export
    end

    if permissions.reports_items_group
      can :group, Reports::Item
    end

    can [:edit, :view], Reports::Category do |category|
      permissions.reports_categories_edit.include?(category.id)
    end

    can :view, Reports::Category do |category|
      permissions.reports_items_read_public.include?(category.id) ||
      permissions.reports_items_create.include?(category.id) ||
      permissions.reports_items_delete.include?(category.id)
    end

    can [:view, :edit, :forward, :alter_status], Reports::Item do |report|
      permissions.reports_items_edit.include?(report.reports_category_id) ||
      permissions.reports_categories_edit.include?(report.reports_category_id)
    end

    can [:view, :create], Reports::Item do |report|
      permissions.reports_items_create.include?(report.reports_category_id) ||
      permissions.reports_categories_edit.include?(report.reports_category_id)
    end

    can [:view, :delete], Reports::Item do |report|
      permissions.reports_items_delete.include?(report.reports_category_id) ||
      permissions.reports_categories_edit.include?(report.reports_category_id)
    end

    can :view, Reports::Item do |report|
      permissions.reports_items_read_private.include?(report.reports_category_id) ||
        permissions.reports_items_read_public.include?(report.reports_category_id) ||
        permissions.reports_categories_edit.include?(report.reports_category_id)
    end

    can :view_private, Reports::Item do |report|
      permissions.reports_items_read_private.include?(report.reports_category_id)
    end

    can :forward, Reports::Item do |report|
      permissions.reports_items_forward.include?(report.reports_category_id) ||
      permissions.reports_items_edit.include?(report.reports_category_id) ||
      permissions.reports_categories_edit.include?(report.reports_category_id)
    end

    can :alter_status, Reports::Item do |report|
      permissions.reports_items_alter_status.include?(report.reports_category_id)
    end

    can [:send_notification, :restart_notification], Reports::Item do |report|
      permissions.reports_items_edit.include?(report.reports_category_id) ||
      permissions.reports_categories_edit.include?(report.reports_category_id) ||
      permissions.manage_reports_categories ||
      permissions.reports_full_access
    end

    can :send_notification, Reports::Item do |report|
      permissions.reports_items_send_notification.include?(report.reports_category_id)
    end

    can :restart_notification, Reports::Item do |report|
      permissions.reports_items_restart_notification.include?(report.reports_category_id)
    end

    can :create_internal, Reports::Comment do |comment|
      report = comment.item
      permissions.reports_items_create_internal_comment.include?(report.reports_category_id) ||
        permissions.reports_items_edit.include?(report.reports_category_id) ||
        permissions.reports_full_access
    end

    can :create, Reports::Comment do |comment|
      report = comment.item
      permissions.reports_items_create_comment.include?(report.reports_category_id) ||
        permissions.reports_items_edit.include?(report.reports_category_id) ||
        permissions.reports_full_access
    end

    if permissions.reports_items_group
      can :group, Reports::Item
    end

    if permissions.reports_items_export
      can :export_reports, Export
    end
  end

  def inventories_permissions
    if permissions.inventories_full_access
      can :manage, Inventory::Category
      can :manage, Inventory::Field
      can :manage, Inventory::Section
      can :manage, Inventory::Item
      can :manage, Export
    end

    if permissions.inventories_formulas_full_access
      can :manage, Inventory::Formula
      can :manage, Inventory::FormulaCondition
    end

    can [:view, :edit], Inventory::Category do |category|
      permissions.inventories_categories_edit.include?(category.id) ||
      permissions.inventories_items_edit.include?(category.id)
    end

    can :view, Inventory::Category do |category|
      permissions.inventories_items_read_only.include?(category.id) ||
      permissions.inventories_items_create.include?(category.id) ||
      permissions.inventories_items_delete.include?(category.id)
    end

    can :view_all_items, Inventory::Category do |category|
      permissions.inventories_items_edit.include?(category.id) ||
      permissions.inventories_categories_edit.include?(category.id) ||
      permissions.inventories_items_read_only.include?(category.id) ||
      permissions.inventories_items_delete.include?(category.id)
    end

    can [:view, :edit], Inventory::Item do |inventory_item|
      permissions.inventories_items_edit.include?(inventory_item.inventory_category_id) ||
      permissions.inventories_categories_edit.include?(inventory_item.inventory_category_id) ||
      (permissions.inventory_fields_can_edit & inventory_item.category.fields.pluck(:id)).any?
    end

    can :view, Inventory::Item do |inventory_item|
      permissions.inventories_items_read_only.include?(inventory_item.inventory_category_id) ||
      permissions.inventories_categories_edit.include?(inventory_item.inventory_category_id)
    end

    can [:view, :create], Inventory::Item do |inventory_item|
      permissions.inventories_items_create.include?(inventory_item.inventory_category_id)
    end

    can [:view, :create], Inventory::Category do |category|
      permissions.inventories_items_create.include?(category.id)
    end

    can [:view, :delete], Inventory::Item do |inventory_item|
      permissions.inventories_items_delete.include?(inventory_item.inventory_category_id) ||
      permissions.inventories_categories_edit.include?(inventory_item.inventory_category_id)
    end

    if permissions.inventories_items_group
      can :group, Inventory::Item
    end

    # Inventory sections permissions
    can [:view, :edit], Inventory::Section do |inventory_section|
      permissions.inventory_sections_can_edit.include?(inventory_section.id)
    end

    can :view, Inventory::Section do |inventory_section|
      permissions.inventory_sections_can_view.include?(inventory_section.id)
    end

    # Inventory fields permissions
    can [:view, :edit], Inventory::Field do |inventory_field|
      permissions.inventory_fields_can_edit.include?(inventory_field.id)
    end

    can :view, Inventory::Field do |inventory_field|
      permissions.inventory_fields_can_view.include?(inventory_field.id)
    end

    if permissions.inventories_items_export
      can :export_inventories, Export
    end
  end

  def flows_permissions
    if permissions.manage_flows
      can :manage, Flow
      can :manage, ResolutionState
      can :manage, Step
      can :manage, Field
      can :manage, Trigger
      can :manage, Case
      can :manage, CaseStep
    end
  end

  def cases_permissions
    if permissions.manage_cases
      can :manage, Case
    end

    can :show, Step do |step|
      can_execute_step      = permissions.can_execute_step.include?(step.id)
      can_view_step         = permissions.can_view_step.include?(step.id)
      can_execute_all_steps = permissions.flow_can_execute_all_steps.include?(step.flow.id)
      can_view_all_steps    = permissions.flow_can_view_all_steps.include?(step.flow.id)
      can_execute_step || can_view_step || can_execute_all_steps || can_view_all_steps
    end

    can :show, Flow do |flow|
      can_execute_step      = (permissions.can_execute_step & flow.step_ids).any?
      can_view_step         = (permissions.can_view_step & flow.step_ids).any?
      can_execute_all_steps = permissions.flow_can_execute_all_steps.include?(flow.id)
      can_view_all_steps    = permissions.flow_can_view_all_steps.include?(flow.id)
      can_execute_step || can_view_step || can_execute_all_steps || can_view_all_steps
    end

    can :show, Case do |_kase|
      can_execute_step      = permissions.can_execute_step.present?
      can_view_step         = permissions.can_view_step.present?
      can_execute_all_steps = permissions.flow_can_execute_all_steps.present?
      can_view_all_steps    = permissions.flow_can_view_all_steps.present?
      can_view_cases_from_reports = cases_visible.any?
      can_execute_step || can_view_step || can_execute_all_steps || can_view_all_steps || can_view_cases_from_reports
    end

    can :update, Case do |kase|
      kase.responsible_user_id == user.id || user.groups.pluck(:id).include?(kase.responsible_group_id)
    end

    can :delete, Case do |kase|
      flow_can_delete_all_cases = permissions.flow_can_delete_all_cases.include?(kase.initial_flow_id)
      flow_can_delete_own_cases = permissions.flow_can_delete_own_cases.include?(kase.initial_flow_id)
      flow_can_delete_all_cases || (flow_can_delete_own_cases && (kase.responsible_user_id == user.id || user.groups.pluck(:id).include?(kase.responsible_group_id)))
    end

    can :restore, Case do |kase|
      flow_can_delete_all_cases = permissions.flow_can_delete_all_cases.include?(kase.initial_flow_id)
      flow_can_delete_own_cases = permissions.flow_can_delete_own_cases.include?(kase.initial_flow_id)
      flow_can_delete_all_cases || (flow_can_delete_own_cases && (kase.responsible_user_id == user.id || user.groups.pluck(:id).include?(kase.responsible_group_id)))
    end

    can :create, CaseStep do |case_step|
      can_execute_step      = permissions.can_execute_step.include?(case_step.step.id)
      can_execute_all_steps = permissions.flow_can_execute_all_steps.include?(case_step.step.flow.id)
      can_execute_step || can_execute_all_steps
    end

    can :update, CaseStep do |case_step|
      can_execute_step      = permissions.can_execute_step.include?(case_step.step.id)
      can_execute_all_steps = permissions.flow_can_execute_all_steps.include?(case_step.step.flow.id)
      can_execute_step || can_execute_all_steps
    end

    can :show, CaseStep do |case_step|
      can_execute_step      = permissions.can_execute_step.include?(case_step.step.id)
      can_view_step         = permissions.can_view_step.include?(case_step.step.id)
      can_execute_all_steps = permissions.flow_can_execute_all_steps.include?(case_step.step.flow.id)
      can_view_all_steps    = permissions.flow_can_view_all_steps.include?(case_step.step.flow.id)
      can_execute_step || can_view_step || can_execute_all_steps || can_view_all_steps
    end
  end

  def business_reports_permissions
    if permissions.business_reports_edit
      can :manage, BusinessReport
    end

    can :view, BusinessReport do |business_report|
      business_reports_visible.include?(business_report.id)
    end
  end

  def chat_rooms_permissions
    if permissions.manage_chat_rooms
      can :manage, ChatRoom
    end

    can :view, ChatRoom do |chat_room|
      chat_rooms_visible.include?(chat_room.id)
    end
  end

  def namespaces_permissions
    if permissions.manage_namespaces
      can :manage, Namespace
    end

    can :show, Namespace do |namespace|
      namespaces_visible.include?(namespace.id) || namespace.default?
    end
  end

  def event_logs_permissions
    if permissions.event_logs_view
      can :view, EventLog
    end
  end
end
