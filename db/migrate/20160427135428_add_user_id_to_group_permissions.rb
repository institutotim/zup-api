class AddUserIdToGroupPermissions < ActiveRecord::Migration
  def change
    add_column :group_permissions, :user_id, :integer
    add_index :group_permissions, :user_id
  end
end
