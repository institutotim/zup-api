class AddTitleToInventoryItem < ActiveRecord::Migration
  def change
    add_column :inventory_items, :title, :string
  end
end
