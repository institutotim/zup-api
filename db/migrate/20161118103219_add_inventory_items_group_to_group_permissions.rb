class AddInventoryItemsGroupToGroupPermissions < ActiveRecord::Migration
  def change
    add_column :group_permissions, :inventories_items_group, :boolean, default: false
  end
end
