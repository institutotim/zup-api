require 'app_helper'

describe Inventory::ItemData do
  context 'with field type of checkbox' do
    let(:field) { create(:inventory_field, kind: 'checkbox') }
    let(:option1) { create(:inventory_field_option, field: field, value: 'Test') }
    let(:option2) { create(:inventory_field_option, field: field, value: 'Test2') }

    let(:valid_content) { [option1.id, option2.id] }

    context 'receiving an array of field option ids as content' do
      let(:item_data) { create(:inventory_item_data, field: field, content: valid_content) }

      it 'stores correctly' do
        item_data.reload
        expect(item_data.inventory_field_option_ids).to eq(valid_content)
      end
    end

    describe '#content' do
      let(:item_data) { create(:inventory_item_data, field: field, content: valid_content) }

      it 'returns an array with selected inventory field option values' do
        expect(item_data.content).to match_array([option1.id, option2.id])
      end
    end
  end
end
