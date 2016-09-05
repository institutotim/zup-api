require 'uri'
require 'net/http'

# Small class to access Mapquest API
class Mapquest
  API_ROOT = 'http://open.mapquestapi.com/%s/v1/%s' unless const_defined?('API_ROOT')

  attr_reader :api_key

  def initialize(api_key = ENV['MAPQUEST_API_KEY'])
    @api_key = api_key
  end

  def request(api_name, method, params)
    uri = URI(format(API_ROOT, api_name, method))
    url_params = URI.encode_www_form(params)

    http = Net::HTTP.new(uri.host, 80)

    req = Net::HTTP::Get.new(uri.path + "?#{url_params}&key=#{api_key}")
    http.request(req)
  end

  def geoposition(full_address, state, country)
    res = request('geocoding', 'address', location: full_address, state: state, country: country, maxResults: 1)
    parse_latitude_response(res)
  end

  def address(latitude, longitude)
    res = request('geocoding', 'reverse', lat: latitude, lng: longitude, maxResults: 1)
    parse_address_response(res)
  end

  private

  def parse_latitude_response(response)
    json = Oj.load(response.body)
    position = json['results'][0]['locations'][0]['latLng']

    {
      latitude: position['lat'],
      longitude: position['lng']
    }
  end

  def parse_address_response(response)
    json = Oj.load(response.body)
    data = json['results'][0]['locations'][0]

    {
      street: data['street'],
      postal_code: data['postalCode'],
      state: data['adminArea3'],
      city: data['adminArea5']
    }
  end
end
