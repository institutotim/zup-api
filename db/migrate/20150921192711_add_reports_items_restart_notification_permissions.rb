class AddReportsItemsRestartNotificationPermissions < ActiveRecord::Migration
  def change
    add_column :group_permissions, :reports_items_restart_notification, :integer, array: true, default: []
  end
end
