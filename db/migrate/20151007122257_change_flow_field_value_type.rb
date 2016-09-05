class ChangeFlowFieldValueType < ActiveRecord::Migration
  def change
    remove_column :fields, :values
    add_column :fields, :values, :string, array: true, default: []
  end
end
