class CreateBusinessReportsTable < ActiveRecord::Migration
  def change
    create_table :business_reports do |t|
      t.string :title
      t.integer :user_id
      t.text :summary
      t.datetime :begin_date
      t.datetime :end_date

      t.timestamps
    end

    create_table :charts do |t|
      t.integer :business_report_id
      t.integer :metric
      t.integer :chart_type
      t.string :title
      t.text :description
      t.datetime :begin_date
      t.datetime :end_date
      t.integer :categories_ids, array: true, default: []
      t.json :data

      t.timestamps
    end
  end
end
