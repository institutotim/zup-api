class AddFieldVersionToTriggerConditions < ActiveRecord::Migration
  def change
    add_column :trigger_conditions, :field_version, :integer, default: 0
  end
end
