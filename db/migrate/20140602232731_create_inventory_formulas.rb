class CreateInventoryFormulas < ActiveRecord::Migration
  def change
    create_table :inventory_formulas do |t|
      t.integer :inventory_category_id
      t.integer :inventory_status_id
      t.integer :inventory_field_id
      t.string :operator
      t.string :content, array: true
      t.integer :groups_to_alert, array: true

      t.timestamps
    end
  end
end
