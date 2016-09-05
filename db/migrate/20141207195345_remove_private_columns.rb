class RemovePrivateColumns < ActiveRecord::Migration
  def change
    remove_column :reports_categories, :private, :boolean
    remove_column :inventory_categories, :private, :boolean
  end
end
