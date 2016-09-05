class AddPrivateToReportsCategory < ActiveRecord::Migration
  def change
    add_column :reports_categories, :private, :boolean, default: false
  end
end
