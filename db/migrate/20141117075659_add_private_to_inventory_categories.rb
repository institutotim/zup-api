class AddPrivateToInventoryCategories < ActiveRecord::Migration
  def change
    add_column :inventory_categories, :private, :boolean, default: false
  end
end
