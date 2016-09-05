class AddNamespaceIdToReportsCategories < ActiveRecord::Migration
  def change
    add_column :reports_categories, :namespace_id, :integer
    add_index :reports_categories, :namespace_id
  end
end
