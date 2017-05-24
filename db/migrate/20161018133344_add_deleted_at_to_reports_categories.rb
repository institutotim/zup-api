class AddDeletedAtToReportsCategories < ActiveRecord::Migration
  def change
    add_column :reports_categories, :deleted_at, :datetime
  end
end
