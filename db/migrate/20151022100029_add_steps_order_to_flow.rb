class AddStepsOrderToFlow < ActiveRecord::Migration
  def change
    add_column :flows, :step_orders, :integer, array: true, default: []
  end
end
