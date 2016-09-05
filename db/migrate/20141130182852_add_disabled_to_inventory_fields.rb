class AddDisabledToInventoryFields < ActiveRecord::Migration
  def change
    add_column :inventory_fields, :disabled, :boolean, default: false
  end
end
