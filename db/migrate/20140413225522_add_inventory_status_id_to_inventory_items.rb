class AddInventoryStatusIdToInventoryItems < ActiveRecord::Migration
  def change
    add_reference :inventory_items, :inventory_status
    add_index :inventory_items, :inventory_status_id
  end
end
