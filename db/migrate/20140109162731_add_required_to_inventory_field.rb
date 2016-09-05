class AddRequiredToInventoryField < ActiveRecord::Migration
  def change
    add_column :inventory_fields, :required, :boolean, default: false
  end
end
