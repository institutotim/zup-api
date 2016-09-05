class AddOrderedNotificationsToReportsCategories < ActiveRecord::Migration
  def change
    add_column :reports_categories, :ordered_notifications, :boolean, default: false
  end
end
