module Inventory
  class GeocodeItem
    attr_reader :item, :geocode_client, :fields

    def initialize(item)
      @item = item
      @geocode_client = GoogleMapsGeocode.new
      @fields = item.category.fields
    end

    def find_address_and_update!
      fail 'Item needs a valid position' unless item.position

      latitude, longitude = item.position.y, item.position.x
      address_data = geocode_client.address(latitude, longitude)

      if address_data
        populate_inventory_fields!(address_data)
        item.save!
      end
    end

    def find_position_and_update!
      fail 'Item needs a valid address' unless item.address

      city = item.represented_data.city
      state = item.represented_data.state
      full_address = "#{item.address}, #{city}, #{state}"

      position_data = geocode_client.position(full_address)

      if position_data
        populate_position_field!(position_data)
        item.save!
      end
    end

    private

    def populate_position_field!(position_data)
      item.position = ::Inventory::Item.rgeo_factory.point(
        position_data[:longitude],
        position_data[:latitude]
      )
    end

    def populate_inventory_fields!(location_data)
      location_fields = fields.location.to_a

      # Address
      address_field = location_fields.select { |f| f.title == 'address' }.first
      address_item_data = item.data.select { |d| d.inventory_field_id == address_field.id }.first
      address_item_data.content = location_data[:street]

      # Postal code
      postal_code_field = location_fields.select { |f| f.title == 'postal_code' }.first
      postal_code_item_data = item.data.select { |d| d.inventory_field_id == postal_code_field.id }.first
      postal_code_item_data.content = location_data[:postal_code]

      # State
      state_field = location_fields.select { |f| f.title == 'state' }.first
      state_item_data = item.data.select { |d| d.inventory_field_id == state_field.id }.first
      state_item_data.content = location_data[:state]

      # City
      city_field = location_fields.select { |f| f.title == 'city' }.first
      city_item_data = item.data.select { |d| d.inventory_field_id == city_field.id }.first
      city_item_data.content = location_data[:city]

      # Latitude
      latitude_field = location_fields.select { |f| f.title == 'latitude' }.first
      latitude_item_data = item.data.select { |d| d.inventory_field_id == latitude_field.id }.first
      latitude_item_data.content = item.position.y

      # Longitude
      longitude_field = location_fields.select { |f| f.title == 'longitude' }.first
      longitude_item_data = item.data.select { |d| d.inventory_field_id == longitude_field.id }.first
      longitude_item_data.content = item.position.x
    end
  end
end
