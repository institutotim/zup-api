class ChangeColumnNullDefaultDeadlineInDaysInReportsNotificationTypes < ActiveRecord::Migration
  def up
    change_column_null :reports_notification_types, :default_deadline_in_days, true
  end

  def down
    change_column_null :reports_notification_types, :default_deadline_in_days, false
  end
end
