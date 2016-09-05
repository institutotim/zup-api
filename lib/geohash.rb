module GeoHash
  def self.distance_to_chars(distance)
    (((Math.log(distance) - 17.26)) / -1.7269).round
  end
end
