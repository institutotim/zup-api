class AddsReportsCustomFieldsManyToMany < ActiveRecord::Migration
  def change
    create_table :reports_category_custom_fields do |t|
      t.integer :reports_category_id, null: false
      t.integer :reports_custom_field_id, null: false

      t.timestamps
    end

    add_index :reports_category_custom_fields,
      [:reports_category_id, :reports_custom_field_id],
      unique: true,
      name: 'unique_category_custom_field_relation'
  end
end
