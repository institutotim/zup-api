class AddExpiresAtToAccessKeys < ActiveRecord::Migration
  def change
    add_column :access_keys, :expires_at, :datetime, null: false
    AccessKey.update_all(expires_at: 2.weeks.from_now, expired: false)
  end
end
