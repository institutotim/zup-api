class AddGuestToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :guest, :boolean, null: false, default: false
  end
end
