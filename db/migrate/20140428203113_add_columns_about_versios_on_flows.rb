class AddColumnsAboutVersiosOnFlows < ActiveRecord::Migration
  def change
    add_column :flows,              :last_version,      :integer, default: 1
    add_column :resolution_states,  :last_version,      :integer, default: 1
    add_column :steps,              :last_version,      :integer, default: 1
    add_column :fields,             :last_version,      :integer, default: 1
    add_column :triggers,           :last_version,      :integer, default: 1
    add_column :trigger_conditions, :last_version,      :integer, default: 1
    add_column :flows,              :last_version_id,   :integer
    add_column :resolution_states,  :last_version_id,   :integer
    add_column :steps,              :last_version_id,   :integer
    add_column :fields,             :last_version_id,   :integer
    add_column :triggers,           :last_version_id,   :integer
    add_column :trigger_conditions, :last_version_id,   :integer
    add_column :cases,              :flow_version,      :integer
  end
end
