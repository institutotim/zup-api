class ChangeColumnTypeValueFromCaseStepDataFields < ActiveRecord::Migration
  def up
    change_column :case_step_data_fields, :value, :text
  end

  def down
    change_column :case_step_data_fields, :value, :string
  end
end
