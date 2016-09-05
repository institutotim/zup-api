class AddNamespaceIdToInventoryItems < ActiveRecord::Migration
  def change
    add_column :inventory_items, :namespace_id, :integer
    add_index :inventory_items, :namespace_id
  end
end
