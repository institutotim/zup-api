class CityShape
  FACTORY = RGeo::Geographic.simple_mercator_factory

  cattr_reader :shape, :geocode

  class << self
    def load(file, geocode)
      @@geocode = geocode
      @@shape = find_shape(file)
    end

    def contains?(latitude, longitude)
      point = FACTORY.point(longitude, latitude)
      shape.geometry.contains?(point)
    end

    def validation_enabled?
      geocode && shape
    end

    private

    def find_shape(file)
      file = RGeo::Shapefile::Reader.open(file.path, factory: FACTORY)

      found_file = nil
      file.each do |record|
        if record.attributes['CD_GEOCODM'].to_i == geocode.to_i || record.attributes['CD_GEOCMU'].to_i == geocode.to_i
          found_file = record
          break
        end
      end

      fail "Geocode specified in CD_GEOCDM was not found: #{geocode}" unless found_file

      found_file
    end
  end
end
