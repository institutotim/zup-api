class CreateTriggers < ActiveRecord::Migration
  def change
    create_table :triggers do |t|
      t.string :title,         null: false, size: 100
      t.string :action_type,   null: false
      t.string :action_values, null: false
      t.references :step,          index: true
      t.integer :order_number,  default: 1

      t.timestamps
    end
  end
end
