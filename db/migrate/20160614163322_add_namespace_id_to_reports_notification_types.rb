class AddNamespaceIdToReportsNotificationTypes < ActiveRecord::Migration
  def change
    add_column :reports_notification_types, :namespace_id, :integer
    add_index :reports_notification_types, :namespace_id
  end
end
