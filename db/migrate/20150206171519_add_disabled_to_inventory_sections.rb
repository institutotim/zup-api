class AddDisabledToInventorySections < ActiveRecord::Migration
  def change
    add_column :inventory_sections, :disabled, :boolean, default: false
  end
end
