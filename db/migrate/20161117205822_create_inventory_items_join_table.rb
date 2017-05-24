class CreateInventoryItemsJoinTable < ActiveRecord::Migration
  def change
    create_table :inventory_items_relationships do |t|
      t.references :inventory_item
      t.references :relationship
    end

    add_index :inventory_items_relationships,
      [:inventory_item_id, :relationship_id], unique: true,
      name: 'index_inventory_items_relationships'
  end
end
