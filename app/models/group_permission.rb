class GroupPermission < ActiveRecord::Base
  include AtomicArrays

  class Boolean
  end

  # Types of permissions
  TYPES = {
    case: {
      'manage_cases' => Boolean,
      'cases_with_reports_view' => [Reports::Category, Array]
    },

    flow: {
      'manage_flows' => Boolean,
      'flow_can_view_all_steps' => [Flow, Array],
      'flow_can_execute_all_steps' => [Flow, Array],
      'flow_can_delete_all_cases' => [Flow, Array],
      'flow_can_delete_own_cases' => [Flow, Array],
    },

    step: {
      'can_view_step' => [Step, Array],
      'can_execute_step' => [Step, Array],
    },

    chat: {
      'manage_chat_rooms' => Boolean,
      'chat_rooms_read' => [ChatRoom, Array]
    },

    user: {
      'users_full_access' => Boolean,
      'users_read_private' => Boolean,
      'manage_services' => Boolean
    },

    group: {
      'group_edit' => [Group, Array],
      'group_read_only' => [Group, Array],
      'groups_full_access' => Boolean,
      'users_edit' => [Group, Array]
    },

    other: {
      'manage_config' => Boolean,
      'panel_access' => Boolean,
      'view_categories' => Boolean,
      'view_sections' => Boolean,
      'event_logs_view' => Boolean
    },

    inventory: {
      'inventories_items_create' => [Inventory::Category, Array],
      'inventories_items_edit' => [Inventory::Category, Array],
      'inventories_items_delete' => [Inventory::Category, Array],
      'inventories_items_read_only' => [Inventory::Category, Array],
      'inventories_categories_edit' => [Inventory::Category, Array],
      'inventories_items_export' => Boolean,
      'inventories_formulas_full_access' => Boolean,
      'inventories_full_access' => Boolean,
      'inventories_items_group' => Boolean
    },

    report: {
      'reports_items_read_public' => [Reports::Category, Array],
      'reports_items_read_private' => [Reports::Category, Array],
      'reports_items_create' => [Reports::Category, Array],
      'reports_items_edit' => [Reports::Category, Array],
      'reports_items_delete' => [Reports::Category, Array],
      'reports_items_forward' => [Reports::Category, Array],
      'reports_items_create_internal_comment' => [Reports::Category, Array],
      'reports_items_create_comment' => [Reports::Category, Array],
      'reports_items_alter_status' => [Reports::Category, Array],
      'reports_items_send_notification' => [Reports::Category, Array],
      'reports_items_restart_notification' => [Reports::Category, Array],
      'reports_categories_edit' => [Reports::Category, Array],
      'reports_items_export' => Boolean,
      'reports_items_group' => Boolean,
      'reports_full_access' => Boolean,
      'manage_reports_categories' => Boolean
    },

    business_report: {
      'business_reports_edit' => Boolean,
      'business_reports_view' => [BusinessReport, Array]
    },

    namespace: {
      'manage_namespaces' => Boolean,
      'namespaces_access' => [Namespace, Array]
    }
  }

  belongs_to :group, touch: true

  def self.permissions_columns
    %w(
      panel_access
      create_reports_from_panel
      users_full_access
      users_read_private
      users_edit
      manage_services
      groups_full_access
      reports_full_access
      inventories_full_access
      inventories_formulas_full_access
      group_edit
      group_read_only
      reports_items_read_public
      reports_items_read_private
      reports_items_create
      reports_items_edit
      reports_items_delete
      reports_items_forward
      reports_items_create_internal_comment
      reports_items_create_comment
      reports_items_alter_status
      reports_items_send_notification
      reports_items_restart_notification
      reports_items_export
      reports_items_group
      reports_categories_edit
      manage_reports_categories
      inventories_items_read_only
      inventories_items_create
      inventories_items_edit
      inventories_items_delete
      inventories_categories_edit
      inventories_category_manage_triggers
      inventory_fields_can_edit
      inventory_fields_can_view
      inventory_sections_can_edit
      inventory_sections_can_view
      inventories_items_group
      flow_can_execute_all_steps
      flow_can_delete_own_cases
      flow_can_delete_all_cases
      flow_can_view_all_steps
      can_view_step
      can_execute_step
      manage_flows
      manage_config
      create_reports_from_panel
      business_reports_edit
      business_reports_view
      manage_chat_rooms
      chat_rooms_read
      manage_cases
      cases_with_reports_view
      manage_namespaces
      namespaces_access
      event_logs_view
    )
  end
end
