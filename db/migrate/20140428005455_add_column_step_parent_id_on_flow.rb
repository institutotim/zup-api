class AddColumnStepParentIdOnFlow < ActiveRecord::Migration
  def change
    add_column :flows, :step_parent_id, :integer
  end
end
