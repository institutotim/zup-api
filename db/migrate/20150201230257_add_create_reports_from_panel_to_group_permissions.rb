class AddCreateReportsFromPanelToGroupPermissions < ActiveRecord::Migration
  def change
    add_column :group_permissions, :create_reports_from_panel, :boolean, default: false
  end
end
