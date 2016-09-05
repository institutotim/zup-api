class AddOverdueToReportsItem < ActiveRecord::Migration
  def change
    add_column :reports_items, :overdue, :boolean, default: false
  end
end
