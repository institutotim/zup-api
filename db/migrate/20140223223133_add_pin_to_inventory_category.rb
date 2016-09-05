class AddPinToInventoryCategory < ActiveRecord::Migration
  def change
    add_column :inventory_categories, :pin, :string
  end
end
