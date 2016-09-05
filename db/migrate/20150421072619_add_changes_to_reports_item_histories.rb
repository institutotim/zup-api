class AddChangesToReportsItemHistories < ActiveRecord::Migration
  def change
    add_column :reports_item_histories, :saved_changes, :json
  end
end
