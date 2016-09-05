class AddsResponsibleGroupIdToReportsStatusesCategories < ActiveRecord::Migration
  def change
    add_column :reports_statuses_reports_categories, :responsible_group_id, :integer
  end
end
