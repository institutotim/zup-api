class AddColorToInventoryCategory < ActiveRecord::Migration
  def change
    add_column :inventory_categories, :color, :string
  end
end
