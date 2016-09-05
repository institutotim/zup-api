class AddConfidentialToReportsItems < ActiveRecord::Migration
  def change
    add_column :reports_items, :confidential, :boolean, default: false
  end
end
