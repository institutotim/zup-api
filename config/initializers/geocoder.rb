Geocoder.configure(
  # geocoding service (see below for supported options):
  lookup: :google,
  # to use an API key:
  api_key: ENV['GOOGLE_API_KEY'],
  # geocoding service request timeout, in seconds (default 3):
  timeout: 5,
  # set default units to kilometers:
  units: :km,
  # caching (see below for details):
  cache: Redis.new,
  cache_prefix: 'geocoding',
  use_https: true
)
