class CreateInventoryItems < ActiveRecord::Migration
  def change
    create_table :inventory_items do |t|
      t.references :inventory_category, index: true
      t.references :user, index: true

      t.timestamps
    end
  end
end
