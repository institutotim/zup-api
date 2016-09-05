class ChangeFieldsCategoriesColumns < ActiveRecord::Migration
  def up
    change_column :fields, :category_inventory_id, 'INTEGER[] USING array[category_inventory_id]::INTEGER[]', default: []
    change_column :fields, :category_report_id, 'INTEGER[] USING array[category_report_id]::INTEGER[]', default: []
  end

  def down
    change_column :fields, :category_inventory_id, :integer
    change_column :fields, :category_report_id, :integer
  end
end
