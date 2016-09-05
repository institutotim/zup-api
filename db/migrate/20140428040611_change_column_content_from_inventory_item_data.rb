class ChangeColumnContentFromInventoryItemData < ActiveRecord::Migration
  def change
    change_column :inventory_item_data, :content, 'text[] USING array[content]'
  end
end
