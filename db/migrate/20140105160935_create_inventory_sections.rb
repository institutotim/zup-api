class CreateInventorySections < ActiveRecord::Migration
  def change
    create_table :inventory_sections do |t|
      t.string :name
      t.references :inventory_category, index: true
      t.hstore :permissions

      t.timestamps
    end
  end
end
