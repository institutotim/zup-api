class AddColumnInitialFlowOnCase < ActiveRecord::Migration
  def change
    add_column :cases, :initial_flow_id, :integer, null: false
    add_index :cases,  :initial_flow_id
  end
end
