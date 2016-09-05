require 'app_helper'

describe Utils::API do
  describe 'GET /utils/city-boundary/validate' do
    let(:url) { '/utils/city-boundary/validate' }
    let(:latitude) { -46.32341 }
    let(:longitude) { -23.134234 }
    let(:valid_params) do
      {
        latitude: latitude,
        longitude: longitude
      }
    end

    context 'validation enabled' do
      before do
        allow(CityShape).to receive(:validation_enabled?).and_return(true)
      end

      context 'points are within boundaries' do
        before do
          allow(CityShape).to receive(:contains?).with(latitude, longitude).and_return(true)
        end

        it 'returns correct response' do
          get url, valid_params
          expect(parsed_body).to match('inside_boundaries' => true)
        end
      end

      context "points aren't within boundaries" do
        before do
          allow(CityShape).to receive(:contains?).with(latitude, longitude).and_return(false)
        end

        it 'returns correct response' do
          get url, valid_params
          expect(parsed_body).to match('inside_boundaries' => false)
        end
      end
    end

    context 'validation disabled' do
      before do
        allow(CityShape).to receive(:validation_enabled?).and_return(false)
      end

      it 'returns a message' do
        get url, valid_params
        expect(parsed_body).to match('message' => an_instance_of(String))
      end
    end
  end
end
