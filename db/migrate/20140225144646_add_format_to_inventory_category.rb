class AddFormatToInventoryCategory < ActiveRecord::Migration
  def change
    add_column :inventory_categories, :format, :string
  end
end
