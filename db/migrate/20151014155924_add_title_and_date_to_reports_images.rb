class AddTitleAndDateToReportsImages < ActiveRecord::Migration
  def change
    add_column :reports_images, :title, :string
    add_column :reports_images, :date, :datetime
  end
end
