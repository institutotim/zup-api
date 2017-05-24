class AddReportsItemsGroupToGroupPermissions < ActiveRecord::Migration
  def change
    add_column :group_permissions, :reports_items_group, :boolean, default: false
  end
end
