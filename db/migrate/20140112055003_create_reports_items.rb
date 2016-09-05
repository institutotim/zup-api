class CreateReportsItems < ActiveRecord::Migration
  def change
    create_table :reports_items do |t|
      t.point :position
      t.text :address
      t.text :description
      t.references :reports_status, index: true
      t.references :reports_category, index: true
      t.references :user, index: true
      t.references :inventory_item, index: true

      t.timestamps
    end
  end
end
