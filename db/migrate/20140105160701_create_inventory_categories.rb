class CreateInventoryCategories < ActiveRecord::Migration
  def change
    create_table :inventory_categories do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
