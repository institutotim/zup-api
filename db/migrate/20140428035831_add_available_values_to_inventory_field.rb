class AddAvailableValuesToInventoryField < ActiveRecord::Migration
  def change
    add_column :inventory_fields, :available_values, :string, array: true
  end
end
