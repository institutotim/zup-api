class AddLockToInventoryItems < ActiveRecord::Migration
  def change
    add_column :inventory_items, :locked, :boolean, default: false
    add_column :inventory_items, :locked_at, :datetime
    add_column :inventory_items, :locker_id, :integer
  end
end
