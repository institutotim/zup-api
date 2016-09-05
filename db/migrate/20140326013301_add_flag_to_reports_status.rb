class AddFlagToReportsStatus < ActiveRecord::Migration
  def change
    add_column :reports_statuses, :active, :boolean, default: true
  end
end
