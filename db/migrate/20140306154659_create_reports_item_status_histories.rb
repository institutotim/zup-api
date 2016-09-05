class CreateReportsItemStatusHistories < ActiveRecord::Migration
  def change
    create_table :reports_item_status_histories do |t|
      t.integer :reports_item_id
      t.integer :previous_status_id
      t.integer :new_status_id

      t.timestamps
    end
  end
end
