class AddTimestampToReportsImages < ActiveRecord::Migration
  def change
    add_column :reports_images, :created_at, :datetime
    add_column :reports_images, :updated_at, :datetime
  end
end
