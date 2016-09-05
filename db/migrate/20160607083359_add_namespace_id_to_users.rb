class AddNamespaceIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :namespace_id, :integer
    add_index :users, :namespace_id
  end
end
