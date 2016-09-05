class AddColumnFlowVersionOnLogEntries < ActiveRecord::Migration
  def change
    add_column :cases_log_entries, :flow_version, :integer
  end
end
