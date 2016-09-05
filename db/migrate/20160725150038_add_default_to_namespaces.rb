class AddDefaultToNamespaces < ActiveRecord::Migration
  def change
    add_column :namespaces, :default, :boolean, default: false, null: false
  end
end
