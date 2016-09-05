class ReorganizeStatus < ActiveRecord::Migration
  def change
    # Updates all disabled statuses
    Reports::StatusCategory.where(disabled: true).update_all(active: false)

    remove_column :reports_statuses_reports_categories, :disabled
  end
end
