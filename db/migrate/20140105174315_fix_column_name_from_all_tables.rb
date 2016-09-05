class FixColumnNameFromAllTables < ActiveRecord::Migration
  def change
    rename_column :inventory_categories, :name, :title
    rename_column :inventory_sections, :name, :title
    rename_column :inventory_fields, :name, :title
  end
end
