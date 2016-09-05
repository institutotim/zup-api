class AddIndexToReportsImagesPosition < ActiveRecord::Migration
  def change
    change_table :reports_items do |t|
      t.index :position, spatial: true
    end
  end
end
