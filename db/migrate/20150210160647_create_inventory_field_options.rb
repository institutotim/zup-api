class CreateInventoryFieldOptions < ActiveRecord::Migration
  def change
    create_table :inventory_field_options do |t|
      t.integer :inventory_field_id
      t.string :value
      t.boolean :disabled, default: false

      t.timestamps
    end

    add_index 'inventory_field_options', ['inventory_field_id'],
      name: 'index_inventory_field_options_on_inventory_field_id'
  end
end
