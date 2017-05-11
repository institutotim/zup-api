class AddGroupKeyToReportsItems < ActiveRecord::Migration
  def change
    add_column :reports_items, :group_key, :string, index: true
  end
end
