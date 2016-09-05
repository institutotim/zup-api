class AddOffensiveColumnToReportsItem < ActiveRecord::Migration
  def change
    add_column :reports_items, :offensive, :boolean, default: false
  end
end
