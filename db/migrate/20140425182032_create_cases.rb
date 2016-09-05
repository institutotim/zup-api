class CreateCases < ActiveRecord::Migration
  def change
    create_table :cases do |t|
      t.integer :created_by_id,    null: false
      t.integer :updated_by_id
      t.integer :responsible_user
      t.integer :responsible_group
      t.hstore :data,             null: false
      t.references :step,             index: true

      t.timestamps
    end
  end
end
