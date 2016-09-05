class ChangeDefaultDeadlineInDaysDefaultValue < ActiveRecord::Migration
  def up
    change_column_default :reports_notification_types, :default_deadline_in_days, 0
  end

  def down
    change_column_default :reports_notification_types, :default_deadline_in_days, nil
  end
end
