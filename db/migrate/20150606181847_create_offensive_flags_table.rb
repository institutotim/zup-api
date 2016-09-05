class CreateOffensiveFlagsTable < ActiveRecord::Migration
  def change
    create_table :reports_offensive_flags do |t|
      t.integer :reports_item_id
      t.integer :user_id

      t.timestamps
    end

    add_index :reports_offensive_flags, [:reports_item_id, :user_id], unique: true
  end
end
