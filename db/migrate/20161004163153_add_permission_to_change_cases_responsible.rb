class AddPermissionToChangeCasesResponsible < ActiveRecord::Migration
  def change
    add_column :group_permissions, :flow_can_change_cases_responsible, :integer, array: true, default: []
  end
end
