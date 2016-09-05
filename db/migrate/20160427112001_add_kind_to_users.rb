class AddKindToUsers < ActiveRecord::Migration
  def change
    add_column :users, :kind, :integer, default: 0, null: false
    add_index :users, :kind
  end
end
