require 'app_helper'

describe Reports::GeocodeItem do
  let(:item) { create(:reports_item) }

  subject { described_class.new(item) }

  describe '#find_position_and_update!' do
    let(:position_data) do
      {
        latitude: 2.782591,
        longitude: -60.728148
      }
    end

    before do
      # Stub geocode client
      allow_any_instance_of(GoogleMapsGeocode).to receive(:position)
                                                    .and_return(position_data)
    end

    it 'populates correctly the item data' do
      subject.find_position_and_update!
      item.reload

      expect(item.position.y).to eq(position_data[:latitude])
      expect(item.position.x).to eq(position_data[:longitude])
    end
  end
end
