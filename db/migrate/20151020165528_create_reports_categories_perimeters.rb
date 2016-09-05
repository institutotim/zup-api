class CreateReportsCategoriesPerimeters < ActiveRecord::Migration
  def change
    create_table :reports_categories_perimeters do |t|
      t.integer :reports_category_id, index: true
      t.integer :reports_perimeter_id, index: true
      t.integer :solver_group_id, index: true

      t.timestamps
    end
  end
end
