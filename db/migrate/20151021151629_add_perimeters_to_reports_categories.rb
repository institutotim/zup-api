class AddPerimetersToReportsCategories < ActiveRecord::Migration
  def change
    add_column :reports_categories, :perimeters, :boolean, default: false, null: false
  end
end
