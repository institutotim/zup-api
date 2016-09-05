class ChangeResolutionTimeEnabledDefault < ActiveRecord::Migration
  def up
    change_column_default :reports_categories, :resolution_time_enabled, false
  end

  def down
    change_column_default :reports_categories, :resolution_time_enabled, true
  end
end
