class CreateInventoryItemData < ActiveRecord::Migration
  def change
    create_table :inventory_item_data do |t|
      t.references :inventory_item, index: true
      t.references :inventory_field, index: true
      t.string :content

      t.timestamps
    end
  end
end
