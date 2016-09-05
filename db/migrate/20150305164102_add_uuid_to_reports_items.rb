class AddUuidToReportsItems < ActiveRecord::Migration
  def change
    add_column :reports_items, :uuid, :uuid
    add_index :reports_items, :uuid

    add_column :reports_items, :external_category_id, :integer
    add_column :reports_items, :is_solicitation, :boolean
    add_column :reports_items, :is_report, :boolean
  end
end
