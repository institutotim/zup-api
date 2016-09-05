class AddVersionToReportsItems < ActiveRecord::Migration
  def change
    add_column :reports_items, :version, :integer, default: 1
    add_column :reports_items, :last_version_at, :datetime
  end
end
