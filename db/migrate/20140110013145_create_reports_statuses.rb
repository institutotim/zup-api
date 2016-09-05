class CreateReportsStatuses < ActiveRecord::Migration
  def change
    create_table :reports_statuses do |t|
      t.string :title
      t.string :color
      t.boolean :initial, default: false
      t.boolean :final, default: false
      t.references :reports_category, index: true

      t.timestamps
    end
  end
end
