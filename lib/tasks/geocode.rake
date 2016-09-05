namespace :geocode do
  desc 'Geocode all inventory items'
  task :inventory_items do
    items = Inventory::Item

    puts "Fetching data for #{items.count} inventory items"

    items.find_in_batches do |items|
      items.each do |item|
        begin
          Inventory::GeocodeItem.new(item).find_position_and_update!
        rescue Geocoder::OverQueryLimitError => e
          GeocodeInventoryItem.perform_in(24.hours, item.id)
        rescue => e
          puts "An error occurred when populating inventory item data: #{e.message}"
        end
      end
    end

    puts 'Done!'
  end
end
