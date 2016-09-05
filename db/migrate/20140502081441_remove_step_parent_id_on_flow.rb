class RemoveStepParentIdOnFlow < ActiveRecord::Migration
  def change
    remove_column :flows, :step_parent_id
  end
end
