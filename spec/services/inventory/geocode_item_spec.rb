require 'app_helper'

describe Inventory::GeocodeItem do
  let(:item) { create(:inventory_item) }

  subject { described_class.new(item) }

  describe '#find_address_and_update!' do
    let(:address_data) do
      {
        street: 'Rua de Teste, 103-104',
        number: '103-104',
        city: 'São Paulo',
        country: 'Brazil',
        state: 'São Paulo'
      }
    end

    before do
      # Stub geocode client
      allow_any_instance_of(GoogleMapsGeocode).to receive(:address)
                                                    .and_return(address_data)
    end

    it 'populates correctly the item data' do
      subject.find_address_and_update!
      item.reload

      expect(item.address).to eq('Rua de Teste, 103-104')

      location_fields = item.category.fields.location.to_a
      address_field = location_fields.select { |f| f.title == 'address' }.first
      address_item_data = item.data.select { |d| d.inventory_field_id == address_field.id }.first
      expect(address_item_data.content).to eq('Rua de Teste, 103-104')
    end
  end

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
