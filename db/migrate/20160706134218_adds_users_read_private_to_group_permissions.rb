class AddsUsersReadPrivateToGroupPermissions < ActiveRecord::Migration
  def change
    add_column :group_permissions, :users_read_private, :boolean, default: false
  end
end
