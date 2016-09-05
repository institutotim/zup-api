class ChangeReportsCustomFieldDataValueType < ActiveRecord::Migration
  def up
    change_column :reports_custom_field_data, :value, :text
  end

  def down
    change_column :reports_custom_field_data, :value, :string
  end
end
