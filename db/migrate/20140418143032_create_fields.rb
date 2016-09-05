class CreateFields < ActiveRecord::Migration
  def change
    create_table :fields do |t|
      t.string :title
      t.string :type
      t.integer :category_inventory_id
      t.integer :category_report_id
      t.integer :origin_field_id
      t.boolean :active,               default: true
      t.references :step,                 index: true

      t.timestamps
    end
  end
end
