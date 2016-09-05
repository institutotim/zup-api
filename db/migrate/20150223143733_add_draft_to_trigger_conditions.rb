class AddDraftToTriggerConditions < ActiveRecord::Migration
  def change
    add_column :trigger_conditions, :draft, :boolean, default: true
    remove_column :trigger_conditions, :last_version, :integer
    remove_column :trigger_conditions, :last_version_id, :integer
  end
end
