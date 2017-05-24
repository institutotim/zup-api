class AddNamespaceIdToExports < ActiveRecord::Migration
  def change
    add_column :exports, :namespace_id, :integer
    add_index :exports, :namespace_id
  end
end
