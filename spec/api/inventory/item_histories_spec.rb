require 'spec_helper'

describe Inventory::ItemHistories::API do
  let(:item) { create(:inventory_item) }
  let(:user) { create(:user) }

  describe 'GET /inventory/items/:id/history' do
    subject do
      get "/inventory/items/#{item.id}/history", valid_params, auth(user)
    end

    context 'no params' do
      let(:histories) { create_list(:inventory_history, 5, :report, item: item) }
      let(:valid_params) { Hash.new }

      it 'returns everything' do
        histories

        subject
        expect(response.status).to eq(200)

        body = parsed_body
        expect(body['histories'].map do |h|
          h['id']
        end).to match_array(histories.map(&:id))
      end

      context 'with field history' do
        let(:history) { create(:inventory_history, :fields, item: item) }

        before do
          item_data = item.data.first
          history.update!(objects: [item_data.field])
          history.item_data_histories.create!(
            item_data: item_data,
            previous_content: 'old content',
            new_content: 'new content'
          )
        end

        it 'return the fields changes' do
          subject
          expect(response.status).to eq(200)

          body = parsed_body
          expect(body['histories']).to_not be_empty

          returned_history = body['histories'].first
          expect(returned_history['id']).to eq(history.id)
          expect(returned_history['fields_changes']).to be_present

          expect(
            returned_history['fields_changes']
          ).to match([
            'field' => an_instance_of(Hash),
            'previous_content' => 'old content',
            'new_content' => 'new content'
          ])
        end
      end
    end

    context 'kind is equal to field' do
      let!(:histories) { create_list(:inventory_history, 5, :field, item: item) }
    end

    context 'by date' do
      let!(:correct_histories) do
        create_list(:inventory_history, 3, :report,
                    item: item, created_at: Date.new(2014, 1, 9))
      end
      let!(:wrong_histories) do
        create_list(:inventory_history, 1, :report,
                    item: item, created_at: Date.new(2014, 1, 14))
      end
      let(:valid_params) do
        {
          created_at: {
            begin: Date.new(2014, 1, 9).iso8601,
            end:   Date.new(2014, 1, 13).iso8601
          }
        }
      end

      it 'returns the correct histories' do
        subject
        expect(response.status).to eq(200)

        body = parsed_body
        expect(body['histories'].map do |h|
          h['id']
        end).to match_array(correct_histories.map(&:id))
      end
    end

    context 'by user' do
      let(:other_user) { create(:user) }
      let!(:correct_histories) do
        create_list(:inventory_history, 3, :report,
                    item: item, user: other_user)
      end
      let!(:wrong_histories) do
        create_list(:inventory_history, 1, :report, item: item)
      end
      let(:valid_params) do
        {
          user_id: other_user.id
        }
      end

      it 'returns the correct histories' do
        subject
        expect(response.status).to eq(200)

        body = parsed_body
        expect(body['histories'].map do |h|
          h['id']
        end).to match_array(correct_histories.map(&:id))
      end
    end

    context 'by kind' do
      let!(:correct_histories) do
        create_list(:inventory_history, 3, :report,
                    item: item)
      end
      let!(:wrong_histories) do
        create_list(:inventory_history, 1, :images, item: item)
      end
      let(:valid_params) do
        {
          kind: 'report'
        }
      end

      it 'returns the correct histories' do
        subject
        expect(response.status).to eq(200)

        body = parsed_body
        expect(body['histories'].map do |h|
          h['id']
        end).to match_array(correct_histories.map(&:id))
      end
    end

    context 'by object' do
      let(:field) { create(:inventory_field) }
      let!(:correct_histories) do
        create_list(:inventory_history, 3, :fields,
                    item: item, objects_ids: [field.id])
      end
      let!(:wrong_histories) do
        create_list(:inventory_history, 1, :images, item: item)
      end
      let(:valid_params) do
        {
          object_id: field.id
        }
      end

      it 'returns the correct histories' do
        subject
        expect(response.status).to eq(200)

        body = parsed_body
        expect(body['histories'].map do |h|
          h['id']
        end).to match_array(correct_histories.map(&:id))
      end
    end
  end
end
