class AddNotificationsForReportsCategories < ActiveRecord::Migration
  def change
    add_column :reports_categories, :notifications, :boolean, default: false
  end
end
