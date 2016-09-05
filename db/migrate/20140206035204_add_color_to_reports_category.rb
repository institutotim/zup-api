class AddColorToReportsCategory < ActiveRecord::Migration
  def change
    add_column :reports_categories, :color, :string
  end
end
