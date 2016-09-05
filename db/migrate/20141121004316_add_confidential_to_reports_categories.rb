class AddConfidentialToReportsCategories < ActiveRecord::Migration
  def change
    add_column :reports_categories, :confidential, :boolean, default: false
  end
end
