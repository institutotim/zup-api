class AddManageServicesToGroupPermissions < ActiveRecord::Migration
  def change
    add_column :group_permissions, :manage_services, :boolean, default: false, null: false
  end
end
