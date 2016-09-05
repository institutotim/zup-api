module Reports
  class GeocodeItem
    attr_reader :item, :geocode_client

    def initialize(item)
      @item = item
      @geocode_client = GoogleMapsGeocode.new
    end

    def find_position_and_update!
      fail 'Item needs a valid address' unless item.address

      full_address = "#{item.address}, #{item.number}, #{item.district}, #{item.city}, #{item.state}"
      position_data = geocode_client.position(full_address)

      if position_data
        populate_position_field!(position_data)
        item.save!
      end
    end

    private

    def populate_position_field!(position_data)
      item.position = ::Reports::Item.rgeo_factory.point(
        position_data[:longitude],
        position_data[:latitude]
      )
    end
  end
end
