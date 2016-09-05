class AddInventoryFieldOptionIdsToInventoryItemData < ActiveRecord::Migration
  def change
    add_column :inventory_item_data, :inventory_field_option_ids, :integer, array: true
    add_index :inventory_item_data, ['inventory_field_option_ids'],
      name: 'index_inventory_item_data_on_inventory_field_option_ids'
  end
end
