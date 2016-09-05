class AddSocialIdsToUser < ActiveRecord::Migration
  def change
    add_column :users, :facebook_user_id, :integer
    add_column :users, :twitter_user_id, :integer
    add_column :users, :google_plus_user_id, :integer
  end
end
