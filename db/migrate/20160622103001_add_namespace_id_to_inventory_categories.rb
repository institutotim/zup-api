class AddNamespaceIdToInventoryCategories < ActiveRecord::Migration
  def change
    add_column :inventory_categories, :namespace_id, :integer
    add_index :inventory_categories, :namespace_id
  end
end
