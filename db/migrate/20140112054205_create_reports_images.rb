class CreateReportsImages < ActiveRecord::Migration
  def change
    create_table :reports_images do |t|
      t.string :image
      t.references :reports_item, index: true
    end
  end
end
