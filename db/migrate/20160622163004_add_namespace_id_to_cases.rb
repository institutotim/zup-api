class AddNamespaceIdToCases < ActiveRecord::Migration
  def change
    add_column :cases, :namespace_id, :integer
    add_index :cases, :namespace_id
  end
end
