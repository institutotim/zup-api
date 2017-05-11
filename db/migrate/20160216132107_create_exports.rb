class CreateExports < ActiveRecord::Migration
  def change
    create_table :exports do |t|
      t.integer :inventory_category_id
      t.integer :user_id
      t.integer :kind, default: 0, null: false
      t.integer :status, default: 0, null: false
      t.string :file
      t.hstore :filters, default: '', null: false

      t.timestamps
    end

    add_index :exports, :user_id
    add_index :exports, :inventory_category_id
  end
end
