class AddOrderNumberOnStep < ActiveRecord::Migration
  def change
    add_column :steps, :order_number, :integer
  end
end
