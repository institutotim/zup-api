class AddLocationToInventorySections < ActiveRecord::Migration
  def change
    add_column :inventory_sections, :location, :boolean, null: false, default: false

    # Fix inventory fields with
    Inventory::Field.location.each do |field|
      field.section.update(location: true)
    end
  end
end
