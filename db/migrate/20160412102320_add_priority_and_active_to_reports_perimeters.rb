class AddPriorityAndActiveToReportsPerimeters < ActiveRecord::Migration
  def change
    add_column :reports_perimeters, :active, :boolean, default: true, null: false
    add_column :reports_perimeters, :priority, :integer, default: 0, null: false
  end
end
