class CreateCaseImages < ActiveRecord::Migration
  def change
    create_table :case_images do |t|
      t.string :image
      t.references :case, index: true

      t.timestamps
    end
  end
end
