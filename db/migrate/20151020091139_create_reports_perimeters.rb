class CreateReportsPerimeters < ActiveRecord::Migration
  def change
    create_table :reports_perimeters do |t|
      t.string :title
      t.string :shp_file
      t.string :shx_file
      t.integer :status, default: 0, null: false, index: true
      t.multi_polygon :geometry, srid: 4326

      t.timestamps
    end
  end
end
