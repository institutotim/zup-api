class CreateInventoryItemDataAttachments < ActiveRecord::Migration
  def change
    create_table :inventory_item_data_attachments do |t|
      t.integer :inventory_item_data_id
      t.string :attachment
    end
  end
end
