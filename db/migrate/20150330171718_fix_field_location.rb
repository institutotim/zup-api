class FixFieldLocation < ActiveRecord::Migration
  def change
    Inventory::Field.where(
      title: %w(latitude longitude address postal_code district city state codlog road_classification)
    ).each do |field|
      field.update(location: true)
    end

    Inventory::Item.where(address: nil).find_in_batches do |items|
      items.each do |item|
        item.valid? && item.save
      end
    end
  end
end
