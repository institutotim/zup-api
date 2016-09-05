class AddNamespaceIdToReportsStatusesReportsCategories < ActiveRecord::Migration
  def change
    add_column :reports_statuses_reports_categories, :namespace_id, :integer
    add_index :reports_statuses_reports_categories, :namespace_id
  end
end
