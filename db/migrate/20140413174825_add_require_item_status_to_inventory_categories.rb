class AddRequireItemStatusToInventoryCategories < ActiveRecord::Migration
  def change
    add_column :inventory_categories, :require_item_status, :boolean, null: false, default: false
  end
end
