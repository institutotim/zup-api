# obtained from here:
# http://stackoverflow.com/questions/9917159/how-to-create-random-geo-points-within-a-distance-d-from-another-geo-point/15627922#15627922
class RandomLocationPoint
  def self.location(lat, lng, max_dist_meters)
    max_radius = Math.sqrt((max_dist_meters**2) / 2.0)

    lat_offset = rand(max_radius) / 1000.0
    lng_offset = rand(max_radius) / 1000.0

    lat += [1, -1].sample * lat_offset
    lng += [1, -1].sample * lng_offset
    lat = [[-90, lat].max, 90].min
    lng = [[-180, lng].max, 180].min

    [lat, lng]
  end
end
