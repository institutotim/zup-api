class AddLevelToInventoryFormulaAlert < ActiveRecord::Migration
  def change
    add_column :inventory_formula_alerts, :level, :integer
  end
end
