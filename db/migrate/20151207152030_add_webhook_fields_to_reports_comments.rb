class AddWebhookFieldsToReportsComments < ActiveRecord::Migration
  def change
    add_column :reports_comments, :from_webhook, :boolean, default: false
  end
end
