class AddAddressToInventoryItem < ActiveRecord::Migration
  def change
    add_column :inventory_items, :address, :string
  end
end
