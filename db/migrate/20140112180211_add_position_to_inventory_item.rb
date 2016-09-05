class AddPositionToInventoryItem < ActiveRecord::Migration
  def change
    add_column :inventory_items, :position, :point
  end
end
