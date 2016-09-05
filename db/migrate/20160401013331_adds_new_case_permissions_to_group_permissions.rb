class AddsNewCasePermissionsToGroupPermissions < ActiveRecord::Migration
  def change
    add_column :group_permissions, :cases_with_reports_view, :integer, array: true, default: []
    add_column :group_permissions, :manage_cases, :boolean, default: false
  end
end
