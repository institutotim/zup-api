class CreateInventoryFormulaHistories < ActiveRecord::Migration
  def change
    create_table :inventory_formula_histories do |t|
      t.integer :inventory_formula_id
      t.integer :inventory_item_id
      t.integer :inventory_formula_alert_id

      t.timestamps
    end
  end
end
