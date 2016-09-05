require 'spec_helper'

describe Search::Inventory::Items::API do
  let(:user)     { create(:user) }
  let(:category) { create(:inventory_category_with_sections) }

  describe 'GET /search/inventory/items' do
    context 'sorting' do
      describe 'inventory item fields' do
        let!(:items) do
          items = create_list(:inventory_item, 3, category: category)
        end

        before do
          get '/search/inventory/items', valid_params, auth(user)
        end

        context 'by title' do
          let(:ordered_ids) do
            items.sort_by { |item| item.title }.map(&:id)
          end

          let(:valid_params) do
            Oj.load <<-JSON
            {
              "sort": "title",
              "order": "asc"
            }
            JSON
          end

          it 'returns the items on the correct order' do
            returned_ids = parsed_body['items'].map { |r| r['id'] }
            expect(returned_ids).to eq(ordered_ids)
          end
        end

        context 'by id' do
          let(:ordered_ids) do
            items.sort_by { |item| item.id }.map(&:id)
          end

          let(:valid_params) do
            Oj.load <<-JSON
            {
              "sort": "id",
              "order": "asc"
            }
            JSON
          end

          it 'returns the items on the correct order' do
            returned_ids = parsed_body['items'].map { |r| r['id'] }
            expect(returned_ids).to eq(ordered_ids)
          end
        end

        context 'by address' do
          let(:ordered_ids) do
            items.sort_by { |item| item.address }.map(&:id)
          end

          let(:valid_params) do
            Oj.load <<-JSON
            {
              "sort": "address",
              "order": "asc"
            }
            JSON
          end

          it 'returns the items on the correct order' do
            returned_ids = parsed_body['items'].map { |r| r['id'] }
            expect(returned_ids).to eq(ordered_ids)
          end
        end

        context 'by address' do
          let(:ordered_ids) do
            items.sort_by { |item| item.created_at }.map(&:id)
          end

          let(:valid_params) do
            Oj.load <<-JSON
            {
              "sort": "created_at",
              "order": "asc"
            }
            JSON
          end

          it 'returns the items on the correct order' do
            returned_ids = parsed_body['items'].map { |r| r['id'] }
            expect(returned_ids).to eq(ordered_ids)
          end
        end

        context 'by address' do
          let(:ordered_ids) do
            items.sort_by { |item| item.updated_at }.map(&:id)
          end

          let(:valid_params) do
            Oj.load <<-JSON
            {
              "sort": "updated_at",
              "order": "asc"
            }
            JSON
          end

          it 'returns the items on the correct order' do
            returned_ids = parsed_body['items'].map { |r| r['id'] }
            expect(returned_ids).to eq(ordered_ids)
          end
        end

        context 'by inventory_category_id' do
          let(:ordered_ids) do
            items.sort_by { |item| item.inventory_category_id }.map(&:id)
          end

          let(:valid_params) do
            Oj.load <<-JSON
            {
              "sort": "inventory_category_id",
              "order": "asc"
            }
            JSON
          end

          # it 'returns the items on the correct order' do
          #   returned_ids = parsed_body['items'].map { |r| r['id'] }
          #   expect(returned_ids).to eq(ordered_ids)
          # end
        end
      end

      context 'by user names' do
        let!(:user) { create(:user, name: 'Robert') }
        let!(:user2) { create(:user, name: 'John') }
        let!(:items) do
          create_list(:inventory_item, 2, category: category)
        end
        let!(:correct_items) do
          item = items.sample
          items.delete(item)
          item.update(user_id: user.id)

          item2 = items.sample
          items.delete(item2)
          item2.update(user_id: user2.id)

          [item2, item]
        end
        let(:valid_params) do
          Oj.load <<-JSON
          {
            "sort": "user_name",
            "order": "asc"
          }
          JSON
        end

        before do
          get '/search/inventory/items', valid_params, auth(user)
        end

        it 'returns the correct items in the correct or' do
          expect(parsed_body['items'].map do |i|
                   i['id']
                 end).to eq(correct_items.map(&:id))
        end
      end

      context 'by category title' do
        let(:categories) { create_list(:inventory_category, 3) }
        let!(:items) do
          categories.map do |c|
            create(:inventory_item, category: c)
          end
        end

        let(:valid_params) do
          Oj.load <<-JSON
          {
            "sort": "category_title",
            "order": "asc"
          }
          JSON
        end

        before do
          get '/search/inventory/items', valid_params, auth(user)
        end

        it 'returns the correct items in the correct or' do
          returned_ids = parsed_body['items'].map { |r| r['id'] }
          ordered_ids = items.sort_by { |item| item.category.title }.map(&:id)

          expect(returned_ids).to eq(ordered_ids)
        end
      end
    end
  end
end
