class AddResolvedAtToReportsItems < ActiveRecord::Migration
  def change
    add_column :reports_items, :resolved_at, :datetime
    PopulateReportsItemsResolvedAt.perform_async
  end
end
