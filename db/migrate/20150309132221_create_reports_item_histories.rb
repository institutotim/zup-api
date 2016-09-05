class CreateReportsItemHistories < ActiveRecord::Migration
  def change
    create_table :reports_item_histories do |t|
      t.integer :reports_item_id
      t.integer :user_id
      t.string :kind
      t.text :action
      t.string :object_type
      t.integer :objects_ids, array: true

      t.timestamps
    end

    add_index :reports_item_histories, :reports_item_id
    add_index :reports_item_histories, :user_id
    add_index :reports_item_histories, :kind
  end
end
