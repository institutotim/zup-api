class CreateInventoryFormulaConditions < ActiveRecord::Migration
  def change
    create_table :inventory_formula_conditions do |t|
      t.integer :inventory_formula_id
      t.integer :inventory_field_id
      t.string :operator
      t.string :content, array: true

      t.timestamps
    end
  end
end
