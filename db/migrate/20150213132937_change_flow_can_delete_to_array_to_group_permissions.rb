class ChangeFlowCanDeleteToArrayToGroupPermissions < ActiveRecord::Migration
  def change
    remove_column :group_permissions, :flow_can_delete_all_cases
    remove_column :group_permissions, :flow_can_delete_own_cases
    add_column :group_permissions, :flow_can_delete_all_cases, :integer, array: true, default: []
    add_column :group_permissions, :flow_can_delete_own_cases, :integer, array: true, default: []
  end
end
