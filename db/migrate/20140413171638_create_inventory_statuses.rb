class CreateInventoryStatuses < ActiveRecord::Migration
  def change
    create_table :inventory_statuses do |t|
      t.belongs_to :inventory_category, index: true
      t.string :color, null: false
      t.string :title, size: 150

      t.timestamps
    end
  end
end
