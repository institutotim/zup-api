require 'app_helper'

describe Search::Inventory::Categories::API do
  let(:user) { create(:user) }

  describe 'GET /search/inventory/categories' do
    let!(:categories) { create_list(:inventory_category, 3) }

    let(:url) { '/search/inventory/categories' }

    context 'searching by title' do
      let!(:desired_category) do
        c = categories.sample
        c.update(
          title: 'nomedeteste'
        )
        c
      end

      it 'returns the correct inventory' do
        get url, { title: 'nome' }, auth(user)

        categories_ids = parsed_body['categories'].map { |c| c['id'] }
        expect(categories_ids).to eq([desired_category.id])
      end
    end

    context 'permission validations' do
      let(:group) { create(:group) }

      before do
        user.update!(groups: [group])
      end

      subject do
        UserAbility.clear_cache
        get url, nil, auth(user)
      end

      context 'with permission to manage inventory category' do
        before do
          group.permission.update!(
            inventories_full_access: true
          )
          user.update!(groups: [group])
        end

        it 'can see the complete list of categories' do
          subject

          returned_ids = parsed_body['categories'].map { |c| c['id'] }
          expected_ids = categories.map(&:id)

          expect(returned_ids).to match_array(expected_ids)
        end
      end

      context 'without permission to manage inventory category' do
        let(:visible_categories) { categories.first(3) }

        before do
          group.permission.update!(
            inventories_items_read_only: visible_categories.map(&:id),
            inventories_full_access: false
          )
          user.update!(groups: [group])
        end

        it 'can see only visible categories' do
          subject

          returned_ids = parsed_body['categories'].map { |c| c['id'] }
          expected_ids = visible_categories.map(&:id)

          expect(returned_ids).to match_array(expected_ids)
        end
      end
    end
  end
end
