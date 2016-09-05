class CreateInventoryAnalyzes < ActiveRecord::Migration
  def change
    create_table :inventory_analyzes do |t|
      t.references :inventory_category
      t.string :title
      t.string :expression

      t.timestamps
    end
  end
end
