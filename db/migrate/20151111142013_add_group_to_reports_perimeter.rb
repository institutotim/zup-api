class AddGroupToReportsPerimeter < ActiveRecord::Migration
  def change
    add_column :reports_perimeters, :solver_group_id, :integer, index: true
  end
end
