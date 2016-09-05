class AddContentToReportsNotifications < ActiveRecord::Migration
  def change
    add_column :reports_notifications, :content, :text
  end
end
