class RemoveCharts < ActiveRecord::Migration
  def change
    drop_table :charts
  end
end
