class SettingDefaultValueForGroupPermissionField < ActiveRecord::Migration
  def change
    change_column :group_permissions, :chat_rooms_read, :integer, array: true, default: []
  end
end
