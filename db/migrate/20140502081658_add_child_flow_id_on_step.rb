class AddChildFlowIdOnStep < ActiveRecord::Migration
  def change
    add_column :steps, :child_flow_id, :integer
  end
end
