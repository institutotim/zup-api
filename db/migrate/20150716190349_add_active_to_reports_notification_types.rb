class AddActiveToReportsNotificationTypes < ActiveRecord::Migration
  def change
    add_column :reports_notification_types, :active, :boolean, default: true
  end
end
