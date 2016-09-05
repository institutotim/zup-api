class CreateInventoryItemHistories < ActiveRecord::Migration
  def change
    create_table :inventory_item_histories do |t|
      t.integer :inventory_item_id
      t.integer :user_id
      t.string :kind
      t.text :action
      t.string :object_type
      t.integer :objects_ids, array: true

      t.timestamps
    end

    add_index :inventory_item_histories, :inventory_item_id
    add_index :inventory_item_histories, :user_id
    add_index :inventory_item_histories, :kind
  end
end
