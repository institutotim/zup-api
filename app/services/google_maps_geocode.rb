class GoogleMapsGeocode
  def address(latitude, longitude)
    results = Geocoder.search([latitude, longitude])

    if results.any?
      result = results.first.data['address_components']
      address_data = normalize_array_of_data(result)

      {
        street: "#{address_data[:route]}, #{address_data[:street_number]}",
        number: address_data[:street_number],
        city: address_data[:administrative_area_level_2],
        state: address_data[:administrative_area_level_1],
        postal_code: address_data[:postal_code_prefix]
      }
    else
      nil
    end
  end

  def position(address)
    results = Geocoder.search(address)

    if results.any?
      position_data = results.first.data['geometry']['location']

      {
        latitude: position_data['lat'],
        longitude: position_data['lng']
      }
    else
      nil
    end
  end

  private

  def normalize_array_of_data(result)
    data = {}

    result.each do |r|
      type = r['types'].first
      content = r['long_name']

      data[type.to_sym] = content
    end

    data
  end
end
