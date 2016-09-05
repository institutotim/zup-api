class ChangeActiveToStatusOnFlow < ActiveRecord::Migration
  def change
    remove_column :flows, :active
    add_column :flows, :status, :string, default: :active
  end
end
