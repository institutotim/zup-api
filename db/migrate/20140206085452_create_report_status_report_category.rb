class CreateReportStatusReportCategory < ActiveRecord::Migration
  def change
    create_table :reports_statuses_reports_categories, id: false do |t|
      t.integer :reports_status_id
      t.integer :reports_category_id
    end

    add_index :reports_statuses_reports_categories,
              [:reports_status_id, :reports_category_id],
              name: 'index_reports_statuses_item_and_status_id'
    add_index :reports_statuses_reports_categories,
              :reports_category_id,
              name: 'index_reports_statuses_item_id'
  end
end
