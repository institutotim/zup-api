class AddDisabledToReportsStatusCategory < ActiveRecord::Migration
  def change
    add_column :reports_statuses_reports_categories, :disabled, :boolean, default: false
  end
end
