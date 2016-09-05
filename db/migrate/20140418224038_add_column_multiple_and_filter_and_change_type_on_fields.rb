class AddColumnMultipleAndFilterAndChangeTypeOnFields < ActiveRecord::Migration
  def change
    add_column :fields, :multiple, :boolean, default: false
    add_column :fields, :filter,   :string
    rename_column :fields, :type,     :field_type
  end
end
