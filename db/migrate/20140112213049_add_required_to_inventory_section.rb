class AddRequiredToInventorySection < ActiveRecord::Migration
  def change
    add_column :inventory_sections, :required, :boolean
  end
end
