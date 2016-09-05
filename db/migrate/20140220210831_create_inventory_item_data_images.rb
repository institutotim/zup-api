class CreateInventoryItemDataImages < ActiveRecord::Migration
  def change
    create_table :inventory_item_data_images do |t|
      t.references :inventory_item_data, index: true
      t.string :image

      t.timestamps
    end
  end
end
