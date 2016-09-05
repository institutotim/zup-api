class AddNamespaceIdToReportsCategoriesPerimeters < ActiveRecord::Migration
  def change
    add_column :reports_categories_perimeters, :namespace_id, :integer
    add_index :reports_categories_perimeters, :namespace_id
  end
end
