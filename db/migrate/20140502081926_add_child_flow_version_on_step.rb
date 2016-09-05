class AddChildFlowVersionOnStep < ActiveRecord::Migration
  def change
    add_column :steps, :child_flow_version, :integer
  end
end
