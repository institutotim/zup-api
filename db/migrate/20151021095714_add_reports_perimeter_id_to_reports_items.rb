class AddReportsPerimeterIdToReportsItems < ActiveRecord::Migration
  def change
    add_column :reports_items, :reports_perimeter_id, :integer, index: true
  end
end
