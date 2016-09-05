class AddOrderNumberOnFields < ActiveRecord::Migration
  def change
    add_column :fields, :order_number, :integer, default: 1
  end
end
