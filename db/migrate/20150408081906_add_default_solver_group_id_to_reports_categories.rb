class AddDefaultSolverGroupIdToReportsCategories < ActiveRecord::Migration
  def change
    add_column :reports_categories, :default_solver_group_id, :integer
  end
end
