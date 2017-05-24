class AddDeletedAtToInventoryCategories < ActiveRecord::Migration
  def change
    add_column :inventory_categories, :deleted_at, :datetime
  end
end
