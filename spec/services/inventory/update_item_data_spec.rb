require 'spec_helper'

describe Inventory::UpdateItemData do
  let!(:category) { create(:inventory_category) }
  let(:item) { create(:inventory_item, category: category) }
  let(:item_data) { item.data.joins(:field).where(inventory_fields: { kind: 'text' }).first }
  let(:user) { create(:user) }
  let(:item_params) do
    {
      'data' => {
        item_data.field.id => 'updated content'
      }
    }
  end

  context 'updating an existant item' do
    it 'updates the item' do
      described_class.new(item, item_params['data'], user).update!
      expect(item_data.reload.content).to eq('updated content')
    end

    it 'creates a history entry' do
      described_class.new(item, item_params['data'], user).update!

      entry = item.histories.last
      expect(entry).to_not be_blank
      expect(entry.objects).to match_array([item_data.field])
    end
  end

  context 'updating an existant item with options' do
    let!(:field) { create(:inventory_field, section: category.sections[0], kind: 'radio') }
    let!(:field_option) { create(:inventory_field_option, field: field) }
    let(:item_data) { item.data.find_by(inventory_field_id: field.id) }

    before do
      item_data.update!(content: field_option.id)
    end

    it "doesn't modify saved content" do
      described_class.new(item.reload, {}, user).update!
      expect(item_data.reload.content).to eq([field_option.id])
    end
  end
end
