class AddNamespaceIdToChatRooms < ActiveRecord::Migration
  def change
    add_column :chat_rooms, :namespace_id, :integer
    add_index :chat_rooms, :namespace_id
  end
end
