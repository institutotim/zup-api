class ChangeResponsibleIdsToResponsibleIdOnCaseStep < ActiveRecord::Migration
  def change
    remove_column :case_steps, :responsible_user_ids
    remove_column :case_steps, :responsible_user_group_ids
    add_column :case_steps, :responsible_user_id,  :integer
    add_column :case_steps, :responsible_group_id, :integer
  end
end
