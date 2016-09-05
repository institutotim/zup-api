class AddColumnValuesOnFields < ActiveRecord::Migration
  def change
    add_column :fields, :values, :hstore
  end
end
