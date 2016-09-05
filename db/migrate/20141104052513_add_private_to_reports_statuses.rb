class AddPrivateToReportsStatuses < ActiveRecord::Migration
  def change
    add_column :reports_statuses, :private, :boolean, default: false
  end
end
