class CreateInventoryFormulaAlerts < ActiveRecord::Migration
  def change
    create_table :inventory_formula_alerts do |t|
      t.integer :inventory_formula_id
      t.integer :groups_alerted, array: true
      t.datetime :sent_at

      t.timestamps
    end
  end
end
