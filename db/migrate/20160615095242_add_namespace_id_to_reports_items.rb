class AddNamespaceIdToReportsItems < ActiveRecord::Migration
  def change
    add_column :reports_items, :namespace_id, :integer
    add_index :reports_items, :namespace_id
  end
end
