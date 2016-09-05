require 'spec_helper'

describe GeocodeReportsItem do
  let!(:item) { create(:reports_item) }

  describe '#perform' do
    it 'find the geocoded position of the item and updates it' do
      service_double = double('reports__geocode_item')
      expect(Reports::GeocodeItem).to receive(:new).with(item).and_return(service_double)
      expect(service_double).to receive(:find_position_and_update!)

      GeocodeReportsItem.new.perform(item.id)
    end

    it 'doesnt raise an error if the item isnt found' do
      expect do
        GeocodeReportsItem.new.perform('fake-id')
      end.to_not raise_error
    end
  end
end
