class FixColorlessReportStatuses < ActiveRecord::Migration
  def change
    execute "UPDATE reports_statuses SET color = '#c7c7c7' WHERE color IS NULL"
  end
end
