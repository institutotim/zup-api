class CreateResolutionState < ActiveRecord::Migration
  def change
    create_table :resolution_states do |t|
      t.references :flow,    index: true
      t.string :title,   size: 100
      t.boolean :default, default: false
      t.boolean :active,  default: true

      t.timestamps
    end
  end
end
