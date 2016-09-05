class CreateInventoryCategoriesReportsCategoriesTable < ActiveRecord::Migration
  def change
    create_table :inventory_categories_reports_categories, id: false do |t|
        t.references :reports_category
        t.references :inventory_category
    end

    add_index :inventory_categories_reports_categories, [:reports_category_id, :inventory_category_id], name: 'rep_cat_inv_cat_index'
  end
end
