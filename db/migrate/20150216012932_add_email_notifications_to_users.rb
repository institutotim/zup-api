class AddEmailNotificationsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_notifications, :boolean, default: true
    add_column :users, :unsubscribe_email_token, :string

    User.where(unsubscribe_email_token: nil).update_all(unsubscribe_email_token: SecureRandom.hex)
  end
end
