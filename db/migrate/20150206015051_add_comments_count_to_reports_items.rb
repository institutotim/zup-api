class AddCommentsCountToReportsItems < ActiveRecord::Migration
  def change
    add_column :reports_items, :comments_count, :integer, default: 0
  end
end
