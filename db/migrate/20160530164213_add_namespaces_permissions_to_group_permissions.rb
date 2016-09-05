class AddNamespacesPermissionsToGroupPermissions < ActiveRecord::Migration
  def change
    add_column :group_permissions, :manage_namespaces, :boolean, default: false, null: false
    add_column :group_permissions, :namespaces_access, :integer, array: true, default: []
  end
end
