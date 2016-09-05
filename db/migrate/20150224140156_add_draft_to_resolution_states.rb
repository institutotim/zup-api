class AddDraftToResolutionStates < ActiveRecord::Migration
  def change
    add_column :resolution_states, :draft, :boolean, default: true
    remove_column :resolution_states, :last_version, :integer
    remove_column :resolution_states, :last_version_id, :integer
  end
end
