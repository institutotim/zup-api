class ChangeHstoreToJsonOnFlows < ActiveRecord::Migration
  def change
    remove_column :flows,    :resolution_states_versions
    remove_column :flows,    :steps_versions
    remove_column :steps,    :fields_versions
    remove_column :steps,    :triggers_versions
    remove_column :triggers, :trigger_conditions_versions

    add_column :flows,    :resolution_states_versions,  :json, default: {}
    add_column :flows,    :steps_versions,              :json, default: {}
    add_column :steps,    :fields_versions,             :json, default: {}
    add_column :steps,    :triggers_versions,           :json, default: {}
    add_column :triggers, :trigger_conditions_versions, :json, default: {}
  end
end
