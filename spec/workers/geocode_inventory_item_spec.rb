require 'spec_helper'

describe GeocodeInventoryItem do
  let!(:item) { create(:inventory_item) }

  describe '#perform' do
    it 'find the geocoded position of the item and updates it' do
      service_double = double('inventory__geocode_item')
      expect(Inventory::GeocodeItem).to receive(:new).with(item).and_return(service_double)
      expect(service_double).to receive(:find_position_and_update!)

      GeocodeInventoryItem.new.perform(item.id)
    end

    it 'doesnt raise an error if the item isnt found' do
      expect do
        GeocodeInventoryItem.new.perform('fake-id')
      end.to_not raise_error
    end
  end
end
