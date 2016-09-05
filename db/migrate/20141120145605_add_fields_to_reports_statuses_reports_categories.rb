class AddFieldsToReportsStatusesReportsCategories < ActiveRecord::Migration
  def change
    add_column :reports_statuses_reports_categories, :id, :primary_key, before: :reports_status_id
    add_column :reports_statuses_reports_categories, :initial, :boolean, default: false
    add_column :reports_statuses_reports_categories, :final, :boolean, default: false
    add_column :reports_statuses_reports_categories, :private, :boolean, default: false
    add_column :reports_statuses_reports_categories, :active, :boolean, default: true
  end
end
