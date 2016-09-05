class CreateInventoryItemDataHistories < ActiveRecord::Migration
  def change
    create_table :inventory_item_data_histories do |t|
      t.integer :inventory_item_history_id, null: false
      t.integer :inventory_item_data_id, null: false
      t.string :previous_content
      t.string :new_content
      t.integer :previous_selected_options_ids, array: true, default: [], null: false
      t.integer :new_selected_options_ids, array: true, default: [], null: false

      t.timestamps
    end

    add_index :inventory_item_data_histories, :inventory_item_history_id, name: 'index_item_data_histories_on_item_history_id'
    add_index :inventory_item_data_histories, :inventory_item_data_id, name: 'index_item_data_histories_on_item_data_id'
  end
end
