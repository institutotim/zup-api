class AddPrivateResolutionTimeToReportsCategories < ActiveRecord::Migration
  def change
    add_column :reports_categories, :private_resolution_time, :boolean, default: false
  end
end
