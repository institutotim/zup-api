class AddPriorityToReportCategories < ActiveRecord::Migration
  def change
    add_column :reports_categories, :priority, :integer
  end
end
