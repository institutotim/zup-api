# The GEOCODM should be a code for the shapefile provided,
# based on the IBGE shapefile schema:
# => ftp://geoftp.ibge.gov.br/malhas_digitais/municipio_2013/
shape_file_path = 'db/shapes/state.shp'

if !Application.config.env.test? && ENV['LIMIT_CITY_BOUNDARIES'].present? && File.exists?(File.expand_path(shape_file_path))
  city_geocode = ENV['GEOCODM']
  fail 'GEOCODM env var should be set if LIMIT_CITY_BOUNDARIES is set' if city_geocode.blank?

  shape_file = File.open(shape_file_path)
  CityShape.load(shape_file, city_geocode)
end
