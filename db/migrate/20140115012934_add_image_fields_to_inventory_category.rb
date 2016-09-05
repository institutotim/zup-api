class AddImageFieldsToInventoryCategory < ActiveRecord::Migration
  def change
    add_column :inventory_categories, :icon, :string
    add_column :inventory_categories, :marker, :string
  end
end
