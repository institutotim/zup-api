class AddResolutionTimeEnabledToReportsCategories < ActiveRecord::Migration
  def change
    add_column :reports_categories, :resolution_time_enabled, :boolean, default: true
  end
end
