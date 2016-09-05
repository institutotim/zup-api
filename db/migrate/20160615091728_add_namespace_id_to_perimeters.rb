class AddNamespaceIdToPerimeters < ActiveRecord::Migration
  def change
    add_column :reports_perimeters, :namespace_id, :integer
    add_index :reports_perimeters, :namespace_id
  end
end
