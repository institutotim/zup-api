class AddPositionToInventorySection < ActiveRecord::Migration
  def change
    add_column :inventory_sections, :position, :integer
  end
end
