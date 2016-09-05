class AddReporterIdToReportsItems < ActiveRecord::Migration
  def change
    add_column :reports_items, :reporter_id, :integer
  end
end
