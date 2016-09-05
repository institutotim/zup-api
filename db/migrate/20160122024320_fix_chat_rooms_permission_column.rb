class FixChatRoomsPermissionColumn < ActiveRecord::Migration
  def change
    change_column_default :group_permissions, :chat_rooms_read, []
    execute <<-SQL
      UPDATE group_permissions SET chat_rooms_read = '{}' WHERE chat_rooms_read IS NULL;
    SQL
  end
end
