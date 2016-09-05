class AddColumnStepIdToFlows < ActiveRecord::Migration
  def change
    add_column :flows, :step_id, :integer
  end
end
