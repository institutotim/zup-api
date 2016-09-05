class AddResolutionStatesVersionsToFlows < ActiveRecord::Migration
  def change
    add_column :flows, :resolution_states_versions, :hstore, default: {}
  end
end
