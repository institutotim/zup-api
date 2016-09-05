class AddNotNullConstraints < ActiveRecord::Migration
  def up
    # Normalize data before changing the columns
    AccessKey.where('expired IS NULL').update_all(expired: false)
    Inventory::Field.where('required IS NULL').update_all(required: false)
    Inventory::Section.where('required IS NULL').update_all(required: false)
    Reports::Category.where('active IS NULL').update_all(active: false)
    Reports::Category.where('allows_arbitrary_position IS NULL').update_all(allows_arbitrary_position: false)
    Reports::Status.where('initial IS NULL').update_all(initial: false)
    Reports::Status.where('final IS NULL').update_all(final: false)

    change_column :access_keys, :expired, :boolean, null: false
    change_column :inventory_fields, :required, :boolean, null: false
    change_column :inventory_sections, :required, :boolean, null: false
    change_column :reports_categories, :active, :boolean, null: false
    change_column :reports_categories, :allows_arbitrary_position, :boolean, null: false
    change_column :reports_statuses, :initial, :boolean, null: false
    change_column :reports_statuses, :final, :boolean, null: false
  end

  def down
  end
end
