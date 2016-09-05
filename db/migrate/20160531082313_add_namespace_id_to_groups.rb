class AddNamespaceIdToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :namespace_id, :integer
    add_index :groups, :namespace_id
  end
end
