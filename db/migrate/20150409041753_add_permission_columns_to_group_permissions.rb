class AddPermissionColumnsToGroupPermissions < ActiveRecord::Migration
  def change
    add_column :group_permissions, :reports_items_forward, :integer, array: true, default: []
    add_column :group_permissions, :reports_items_create_internal_comment, :integer, array: true, default: []
    add_column :group_permissions, :reports_items_create_comment, :integer, array: true, default: []
    add_column :group_permissions, :reports_items_alter_status, :integer, array: true, default: []
  end
end
