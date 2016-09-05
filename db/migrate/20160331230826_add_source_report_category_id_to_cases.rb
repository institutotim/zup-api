class AddSourceReportCategoryIdToCases < ActiveRecord::Migration
  def change
    add_column :cases, :source_reports_category_id, :integer
    add_index :cases, [:source_reports_category_id]
  end
end
