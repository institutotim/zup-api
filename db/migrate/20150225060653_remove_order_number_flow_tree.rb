class RemoveOrderNumberFlowTree < ActiveRecord::Migration
  def change
    remove_column :steps,    :order_number, :integer
    remove_column :triggers, :order_number, :integer
    remove_column :fields,   :order_number, :integer
  end
end
