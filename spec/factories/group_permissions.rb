FactoryGirl.define do
  factory :group_permission do
    trait :full_permissions do
      manage_flows true
      flow_can_view_all_steps [1]
      flow_can_execute_all_steps [2]
      flow_can_delete_all_cases [3]
      flow_can_delete_own_cases [4]
      can_view_step [5]
      can_execute_step [6]
      users_full_access true
      group_edit [7]
      group_read_only [8]
      groups_full_access true
      users_edit [9]
      manage_config true
      panel_access true
      inventories_items_create [10]
      inventories_items_edit [11]
      inventories_items_delete [12]
      inventories_items_read_only [13]
      inventories_categories_edit [14]
      inventories_formulas_full_access true
      inventories_full_access true
      reports_items_read_public [15]
      reports_items_read_private [16]
      reports_items_create [17]
      reports_items_edit [18]
      reports_items_delete [19]
      reports_items_forward [20]
      reports_items_create_internal_comment [21]
      reports_items_create_comment [22]
      reports_items_alter_status [23]
      reports_items_send_notification [24]
      reports_items_restart_notification [25]
      reports_categories_edit [26]
      reports_full_access true
      manage_reports_categories true
      business_reports_edit true
      business_reports_view [27]
      manage_services true
    end

    factory :admin_permissions do
      users_full_access true
      inventories_full_access true
      groups_full_access true
      reports_full_access true
      manage_flows true
      inventories_formulas_full_access true
      manage_config true
      panel_access true
      create_reports_from_panel true
      business_reports_edit true
      manage_namespaces true
      manage_chat_rooms true
      manage_services true
    end
  end
end
