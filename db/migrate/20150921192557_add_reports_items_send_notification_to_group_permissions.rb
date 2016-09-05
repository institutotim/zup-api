class AddReportsItemsSendNotificationToGroupPermissions < ActiveRecord::Migration
  def change
    add_column :group_permissions, :reports_items_send_notification, :integer, array: true, default: []
  end
end
