class AddPermanentToAccessKeys < ActiveRecord::Migration
  def change
    add_column :access_keys, :permanent, :boolean, default: false, null: false
  end
end
