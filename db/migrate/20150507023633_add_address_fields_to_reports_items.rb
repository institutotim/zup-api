class AddAddressFieldsToReportsItems < ActiveRecord::Migration
  def change
    add_column :reports_items, :number, :string
    add_column :reports_items, :district, :string
    add_column :reports_items, :postal_code, :string
    add_column :reports_items, :city, :string
    add_column :reports_items, :state, :string
    add_column :reports_items, :country, :string
  end
end
