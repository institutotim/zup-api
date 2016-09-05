class AddBusinessReportPermissionsColumns < ActiveRecord::Migration
  def change
    add_column :group_permissions, :business_reports_edit, :boolean
    add_column :group_permissions, :business_reports_view, :integer, array: true, default: []
  end
end
