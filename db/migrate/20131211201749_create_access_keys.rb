class CreateAccessKeys < ActiveRecord::Migration
  def change
    create_table :access_keys do |t|
      t.belongs_to :user, index: true
      t.string :key
      t.boolean :expired, default: false
      t.datetime :expired_at

      t.timestamps
    end

    add_index :access_keys, :key
  end
end
