class AddUserToFlowsTree < ActiveRecord::Migration
  def change
    add_column :steps,              :user_id, :integer
    add_column :resolution_states,  :user_id, :integer
    add_column :triggers,           :user_id, :integer
    add_column :trigger_conditions, :user_id, :integer
    add_column :fields,             :user_id, :integer
  end
end
