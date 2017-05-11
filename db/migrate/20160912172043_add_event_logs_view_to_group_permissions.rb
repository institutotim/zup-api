class AddEventLogsViewToGroupPermissions < ActiveRecord::Migration
  def change
    add_column :group_permissions, :event_logs_view, :boolean, null: false, default: false
  end
end
