class CreateFlows < ActiveRecord::Migration
  def change
    create_table :flows do |t|
      t.string :title,          size: 100
      t.text :description,    size: 600
      t.integer :created_by_id,  null: false
      t.integer :updated_by_id
      t.boolean :initial,        default: false
      t.boolean :active,         default: true

      t.timestamps
    end
  end
end
