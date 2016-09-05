class RenameCustomFields < ActiveRecord::Migration
  def change
    if table_exists?(:reports_custom_fields)
      rename_table :reports_custom_fields, :reports_custom_field
    end

    if table_exists?(:reports_custom_fields_data)
      rename_table :reports_custom_fields_data, :reports_custom_field_data
    end
  end
end
