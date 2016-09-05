class AddColumnActiveOnTriggersAndTriggerConditions < ActiveRecord::Migration
  def change
    add_column :triggers, :active, :boolean, default: true
    add_column :trigger_conditions, :active, :boolean, default: true
  end
end
