class ChangeCurrentVersionToFlows < ActiveRecord::Migration
  def change
    change_column :flows, :current_version, :integer, default: nil
  end
end
