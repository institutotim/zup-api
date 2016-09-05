class GeocodeInventoryItem
  include Sidekiq::Worker

  def perform(inventory_item_id)
    item = Inventory::Item.find_by(id: inventory_item_id)

    if item
      begin
        Inventory::GeocodeItem.new(item).find_position_and_update!
      rescue Geocoder::OverQueryLimitError => e
        GeocodeInventoryItem.perform_in(24.hours, item.id)
      end
    end
  end
end
