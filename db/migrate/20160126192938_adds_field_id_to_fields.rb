class AddsFieldIdToFields < ActiveRecord::Migration
  def change
    add_column :fields, :field_id, :integer
  end
end
