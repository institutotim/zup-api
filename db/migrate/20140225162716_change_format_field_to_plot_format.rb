class ChangeFormatFieldToPlotFormat < ActiveRecord::Migration
  def change
    rename_column :inventory_categories, :format, :plot_format
  end
end
