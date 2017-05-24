class AddOriginToReportsImages < ActiveRecord::Migration
  def change
    add_column :reports_images, :origin, :integer, default: 0, null: false
  end
end
