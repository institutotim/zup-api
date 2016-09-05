class UnlockInventoryItems
  include Sidekiq::Worker

  sidekiq_options queue: :critical

  # Send push notification for mobile clients
  def perform
    Inventory::Item.locked.each do |item|
      Inventory::ItemLocking.new(item).unlock_if_expired!
    end
  end
end
