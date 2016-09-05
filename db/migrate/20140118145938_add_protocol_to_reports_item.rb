class AddProtocolToReportsItem < ActiveRecord::Migration
  def change
    add_column :reports_items, :protocol, :bigint
    add_index :reports_items, :protocol
  end
end
