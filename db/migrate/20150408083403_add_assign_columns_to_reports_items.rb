class AddAssignColumnsToReportsItems < ActiveRecord::Migration
  def change
    add_column :reports_items, :assigned_group_id, :integer
    add_column :reports_items, :assigned_user_id, :integer
  end
end
