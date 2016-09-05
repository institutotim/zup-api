class AddsReportsCustomFieldsStructure < ActiveRecord::Migration
  def change
    create_table :reports_custom_fields do |t|
      t.string :title, null: false
      t.boolean :multiline, null: false

      t.timestamps
    end

    create_table :reports_custom_field_data do |t|
      t.integer :reports_custom_field_id, null: false
      t.integer :reports_item_id, null: false
      t.string :value

      t.timestamps
    end

    add_index :reports_custom_field_data, :reports_custom_field_id
    add_index :reports_custom_field_data, :reports_item_id
  end
end
