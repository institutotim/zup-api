class AddValidationFieldsToInventoryFields < ActiveRecord::Migration
  def change
    add_column :inventory_fields, :maximum, :integer
    add_column :inventory_fields, :minimum, :integer
  end
end
