class AddOriginFieldVersionToFields < ActiveRecord::Migration
  def change
    add_column :fields, :origin_field_version, :integer
  end
end
