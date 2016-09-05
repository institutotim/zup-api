class AddConditionableColumnForInventoryFormulaConditions < ActiveRecord::Migration
  def change
    add_column :inventory_formula_conditions, :conditionable_type, :string
    rename_column :inventory_formula_conditions, :inventory_field_id, :conditionable_id
  end
end
