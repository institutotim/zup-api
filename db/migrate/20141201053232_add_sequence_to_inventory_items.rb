class AddSequenceToInventoryItems < ActiveRecord::Migration
  def change
    add_column :inventory_items, :sequence, :integer, default: 0

    Inventory::Category.all.each do |category|
      i = 1
      category.items.each do |item|
        item.title = category.title
        item.sequence = i
        item.save(validate: false)
        i += 1
      end
    end
  end
end
