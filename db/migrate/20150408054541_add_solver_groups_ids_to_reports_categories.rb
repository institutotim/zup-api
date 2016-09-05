class AddSolverGroupsIdsToReportsCategories < ActiveRecord::Migration
  def change
    add_column :reports_categories, :solver_groups_ids, :integer, array: true, default: []
  end
end
