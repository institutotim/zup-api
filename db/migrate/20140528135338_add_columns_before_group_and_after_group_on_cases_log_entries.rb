class AddColumnsBeforeGroupAndAfterGroupOnCasesLogEntries < ActiveRecord::Migration
  def change
    add_column :cases_log_entries, :before_group_id, :integer
    add_column :cases_log_entries, :after_group_id,  :integer
  end
end
