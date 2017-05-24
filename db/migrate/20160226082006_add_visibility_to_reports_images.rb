class AddVisibilityToReportsImages < ActiveRecord::Migration
  def change
    add_column :reports_images, :visibility, :integer, default: 0, null: false
  end
end
