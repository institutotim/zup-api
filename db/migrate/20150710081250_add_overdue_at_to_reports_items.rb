class AddOverdueAtToReportsItems < ActiveRecord::Migration
  def change
    add_column :reports_items, :overdue_at, :datetime
    PopulateReportsItemsResolvedAt.perform_async
  end
end
