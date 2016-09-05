class AddParentIdToReportsCategory < ActiveRecord::Migration
  def change
    add_column :reports_categories, :parent_id, :integer, default: nil
    add_index :reports_categories, :parent_id
  end
end
