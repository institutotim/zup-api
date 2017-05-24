class AddOriginToReportsItems < ActiveRecord::Migration
  def change
    add_column :reports_items, :origin, :integer, default: 0, null: false
  end
end
