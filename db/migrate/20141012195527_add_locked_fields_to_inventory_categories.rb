class AddLockedFieldsToInventoryCategories < ActiveRecord::Migration
  def change
    add_column :inventory_categories, :locked, :boolean, default: false
    add_column :inventory_categories, :locked_at, :datetime
    add_column :inventory_categories, :locker_id, :integer
  end
end
