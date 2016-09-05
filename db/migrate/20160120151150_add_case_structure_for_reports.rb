class AddCaseStructureForReports < ActiveRecord::Migration
  def change
    add_column :reports_categories, :flow_id, :integer
    add_column :reports_items, :case_id, :integer
    add_column :reports_statuses_reports_categories, :create_case, :boolean
  end
end
