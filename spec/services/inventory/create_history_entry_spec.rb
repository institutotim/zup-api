require 'spec_helper'

describe Inventory::CreateHistoryEntry do
  let(:item) { create(:inventory_item) }
  let(:user) { create(:user) }

  subject { described_class.new(item, user) }

  describe '#create' do
    context 'with a report created' do
      let(:report) { create(:reports_item) }
      let(:kind) { 'added' }
      let(:action) { 'Criou uma solicitação para o item' }

      it 'creates the history entry' do
        subject.create(kind, action, report)

        entry = Inventory::ItemHistory.find_by(
          kind: kind,
          action: action,
          user_id: user.id,
          inventory_item_id: item.id
        )

        expect(entry).to_not be_nil
        expect(entry.objects).to match_array([report])
      end
    end

    context 'with images added' do
      let(:images) { create_list(:inventory_item_data_image, 3) }
      let(:kind) { 'added' }
      let(:action) { 'Criou uma solicitação para o item' }

      it 'creates the history entry' do
        subject.create(kind, action, images)

        entry = Inventory::ItemHistory.find_by(
          kind: kind,
          action: action,
          user_id: user.id,
          inventory_item_id: item.id
        )

        expect(entry).to be_present
        expect(entry.objects).to match_array(images)
      end
    end

    context 'with item data added' do
      let(:item_data) { create_list(:inventory_item_data, 3, item: item) }
      let(:kind) { 'fields' }
      let(:action) { 'Alterou campos' }
      let(:data) do
        data = {}

        item_data.each do |d|
          data[d] = {
            old: 'old content',
            new: 'new content'
          }
        end

        data
      end

      it 'creates the history entry' do
        subject.create(kind, action, data)

        entry = Inventory::ItemHistory.find_by(
          kind: kind,
          action: action,
          user_id: user.id,
          inventory_item_id: item.id
        )

        expect(entry).to be_present
        expect(entry.objects).to match_array(item_data.map(&:field))
        expect(entry.item_data_histories).to be_present
        expect(entry.item_data_histories.size).to eq(item_data.size)

        entry.item_data_histories.each do |history|
          expect(data[history.item_data]).to be_present
          expect(history.previous_content).to eq(data[history.item_data][:old])
          expect(history.new_content).to eq(data[history.item_data][:new])
        end
      end
    end

    context 'with item data with options added' do
      let(:field) { create(:inventory_field, section: item.category.sections.last, kind: 'radio') }
      let(:field_option) { create(:inventory_field_option, field: field, value: 'Yes') }
      let(:new_field_option) { create(:inventory_field_option, field: field, value: 'No') }
      let(:item_data) { create(:inventory_item_data, item: item, field: field, content: [field_option.id]) }
      let(:kind) { 'fields' }
      let(:action) { 'Alterou campos' }
      let(:data) do
        {
          item_data => {
            old: [field_option.id],
            new: [new_field_option.id]
          }
        }
      end

      it 'creates the history entry' do
        subject.create(kind, action, data)

        entry = Inventory::ItemHistory.find_by(
          kind: kind,
          action: action,
          user_id: user.id,
          inventory_item_id: item.id
        )

        expect(entry).to be_present
        expect(entry.objects).to match_array(item_data.field)
        expect(entry.item_data_histories).to be_present

        history = entry.item_data_histories.find_by(
          inventory_item_data_id: item_data.id
        )
        expect(history.previous_content).to eq(field_option.value)
        expect(history.new_content).to eq(new_field_option.value)
      end
    end
  end
end
