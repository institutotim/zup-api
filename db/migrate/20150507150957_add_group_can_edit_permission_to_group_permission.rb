class AddGroupCanEditPermissionToGroupPermission < ActiveRecord::Migration
  def change
    add_column :group_permissions, :users_edit, :integer, array: true, default: []
  end
end
