class CreateTriggerConditions < ActiveRecord::Migration
  def change
    create_table :trigger_conditions do |t|
      t.references :field,          index: true
      t.string :condition_type, null: false
      t.string :values,         null: false
      t.references :trigger,        index: true

      t.timestamps
    end
  end
end
