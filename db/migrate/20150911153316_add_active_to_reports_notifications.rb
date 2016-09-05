class AddActiveToReportsNotifications < ActiveRecord::Migration
  def change
    add_column :reports_notifications, :active, :boolean, default: true, null: false
  end
end
