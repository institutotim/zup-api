class AddColumnOldStatusOnCases < ActiveRecord::Migration
  def change
    add_column :cases, :old_status, :string, size: 50
  end
end
