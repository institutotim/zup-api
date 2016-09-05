class RenameStepOrdersColumn < ActiveRecord::Migration
  def change
    rename_column :flows, :step_orders, :steps_order
  end
end
