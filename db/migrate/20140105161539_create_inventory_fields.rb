class CreateInventoryFields < ActiveRecord::Migration
  def change
    create_table :inventory_fields do |t|
      t.string :name
      t.string :kind
      t.string :size
      t.integer :position
      t.references :inventory_section, index: true
      t.hstore :options
      t.hstore :permissions

      t.timestamps
    end
  end
end
