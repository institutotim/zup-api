class AddWebhookFieldsToReportsItems < ActiveRecord::Migration
  def change
    add_column :reports_items, :from_webhook, :boolean, default: false
    add_column :reports_items, :sync_at, :datetime
  end
end
