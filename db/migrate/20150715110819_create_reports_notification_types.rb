class CreateReportsNotificationTypes < ActiveRecord::Migration
  def change
    create_table(:reports_notification_types) do |t|
      t.integer :reports_category_id, null: false
      t.string :title
      t.integer :order
      t.integer :reports_status_id
      t.integer :default_deadline_in_days, null: false
      t.text :layout

      t.timestamps
    end
  end
end
