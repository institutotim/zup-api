class AddChatPermissionColumns < ActiveRecord::Migration
  def change
    add_column :group_permissions, :manage_chat_rooms, :boolean
    add_column :group_permissions, :chat_rooms_read, :integer, array: true
  end
end
