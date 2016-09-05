require 'spec_helper'

describe Inventory::RenderItemWithData do
  let(:item) { create(:inventory_item) }

  context 'rendering the existant item' do
    it 'renderse the item from database' do
      data = described_class.new(item).render
      expect(data['id']).to eq(item.id)
      expect(data['data']).to_not be_empty
      expect(data['data'].first['content']).to eq(item.data.first.content)
    end
  end
end
