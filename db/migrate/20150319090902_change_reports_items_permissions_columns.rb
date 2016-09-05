class ChangeReportsItemsPermissionsColumns < ActiveRecord::Migration
  def change
    rename_column :group_permissions, :reports_items_read_only, :reports_items_read_public
    add_column :group_permissions, :reports_items_read_private, :integer, array: true, default: [], after: :reports_items_read_public
  end
end
