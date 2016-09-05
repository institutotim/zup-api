class CreateReportsCategories < ActiveRecord::Migration
  def change
    create_table :reports_categories do |t|
      t.string :title
      t.string :icon
      t.string :marker
      t.integer :resolution_time
      t.integer :user_response_time
      t.boolean :active, default: true
      t.boolean :allows_arbitrary_position, default: false

      t.timestamps
    end
  end
end
