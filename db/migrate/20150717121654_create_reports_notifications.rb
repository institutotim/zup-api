class CreateReportsNotifications < ActiveRecord::Migration
  def change
    create_table(:reports_notifications) do |t|
      t.integer :user_id
      t.integer :reports_item_id
      t.integer :reports_notification_type_id
      t.integer :previous_status_id
      t.integer :deadline_in_days

      t.timestamps
      t.datetime :overdue_at
    end

    add_index :reports_notifications, [:reports_item_id]
    add_index :reports_notifications, [:user_id]
  end
end
