class AddReportsItemsExportAndInventoriesItemsExportPermissions < ActiveRecord::Migration
  def change
    add_column :group_permissions, :reports_items_export, :boolean, default: false
    add_column :group_permissions, :inventories_items_export, :boolean, default: false
  end
end
