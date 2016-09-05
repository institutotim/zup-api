class CreateSteps < ActiveRecord::Migration
  def change
    create_table :steps do |t|
      t.string :title
      t.text :description
      t.string :step_type
      t.references :flow,         index: true

      t.timestamps
    end
  end
end
