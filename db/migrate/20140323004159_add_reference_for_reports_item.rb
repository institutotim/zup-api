class AddReferenceForReportsItem < ActiveRecord::Migration
  def change
    add_column :reports_items, :reference, :string
  end
end
