class AddFlowIdToStatusCategories < ActiveRecord::Migration
  def change
    add_column :reports_statuses_reports_categories, :flow_id, :integer
  end
end
