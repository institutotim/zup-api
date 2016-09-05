namespace :groups do
  desc 'Convert old permissions (hstore) to the new structure'
  task migrate_permissions: :environment do
    # Getting all groups
    groups = Group.all

    groups.each do |group|
      # Create the group permission record if it doesn't have it
      if group.permission.blank?
        permission = GroupPermission.new(group: group)

        # Migrate all booleans columns
        permission.manage_flows = group.manage_flows
        permission.manage_users = group.manage_users
        permission.manage_inventory_categories = group.manage_inventory_categories
        permission.manage_inventory_items = group.manage_inventory_items
        permission.manage_groups = group.manage_groups
        permission.manage_reports_categories = group.manage_reports_categories
        permission.manage_reports = group.manage_reports
        permission.manage_inventory_formulas = group.manage_inventory_formulas
        permission.manage_config = group.manage_config
        permission.delete_inventory_items = group.delete_inventory_items
        permission.delete_reports = group.delete_reports
        permission.edit_inventory_items = group.edit_inventory_items
        permission.edit_reports = group.edit_reports
        permission.view_categories = group.view_categories
        permission.view_sections = group.view_sections
        permission.edit_reports = group.edit_reports
        permission.delete_reports = group.delete_reports
        permission.panel_access = group.panel_access
        permission.flow_can_delete_own_cases = group.flow_can_delete_own_cases
        permission.flow_can_delete_all_cases = group.flow_can_delete_all_cases

        # Migrate all array columns
        permission.groups_can_edit = group.groups_can_edit
        permission.groups_can_view = group.groups_can_view
        permission.reports_categories_can_edit = group.reports_categories_can_edit
        permission.reports_categories_can_view = group.reports_categories_can_view
        permission.inventory_categories_can_edit = group.inventory_categories_can_edit
        permission.inventory_categories_can_view = group.inventory_categories_can_view
        permission.inventory_sections_can_view = group.inventory_sections_can_view
        permission.inventory_sections_can_edit = group.inventory_sections_can_edit
        permission.inventory_fields_can_edit = group.inventory_fields_can_edit
        permission.inventory_fields_can_view = group.inventory_fields_can_view
        permission.flow_can_view_all_steps = group.flow_can_view_all_steps
        permission.flow_can_execute_all_steps = group.flow_can_execute_all_steps
        permission.flow_can_execute_all_steps = group.flow_can_execute_all_steps
        permission.can_view_step = group.can_view_step
        permission.can_execute_step = group.can_execute_step

        if permission.save
          puts "[SUCCESS] Permissions for group ##{group.id} migrated successfully"
        else
          puts '[ERROR] Error migrating permissions for the group'
        end
      end
    end
  end
end
