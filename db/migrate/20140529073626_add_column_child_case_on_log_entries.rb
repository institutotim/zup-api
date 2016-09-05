class AddColumnChildCaseOnLogEntries < ActiveRecord::Migration
  def change
    add_column :cases_log_entries, :child_case_id, :integer
  end
end
