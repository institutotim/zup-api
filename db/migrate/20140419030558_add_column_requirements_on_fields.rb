class AddColumnRequirementsOnFields < ActiveRecord::Migration
  def change
    add_column :fields, :requirements, :hstore
  end
end
