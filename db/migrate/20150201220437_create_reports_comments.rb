class CreateReportsComments < ActiveRecord::Migration
  def change
    create_table :reports_comments do |t|
      t.integer :reports_item_id
      t.integer :visibility, default: 0
      t.integer :author_id
      t.text :message

      t.timestamps
    end
  end
end
