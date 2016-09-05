class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name
      t.hstore :permissions

      t.timestamps
    end
  end
end
