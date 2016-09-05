class AddIndexesOnFlowsChildrenAndCase < ActiveRecord::Migration
  def change
    add_index :flows, :initial
    add_index :flows, :step_id
    add_index :flows, [:status, :current_version, :draft]
    add_index :resolution_states, :active
    add_index :resolution_states, :draft
    add_index :resolution_states, :default
    add_index :steps, [:step_type, :flow_id, :active]
    add_index :steps, :draft
    add_index :fields, :draft
    add_index :fields, :active
    add_index :fields, :field_type
    add_index :triggers, :draft
    add_index :triggers, :active
    add_index :trigger_conditions, :draft
    add_index :trigger_conditions, :active
    add_index :cases, [:initial_flow_id, :flow_version]
    add_index :cases, [:created_by_id, :updated_by_id]
    add_index :cases, :status
    add_index :cases, :original_case_id
    add_index :case_steps, :responsible_user_id
    add_index :case_steps, :responsible_group_id
    add_index :case_steps, [:created_by_id, :updated_by_id]
  end
end
