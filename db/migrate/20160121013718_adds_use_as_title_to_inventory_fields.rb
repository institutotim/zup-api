class AddsUseAsTitleToInventoryFields < ActiveRecord::Migration
  def change
    add_column :inventory_fields, :use_as_title, :boolean, default: false
  end
end
