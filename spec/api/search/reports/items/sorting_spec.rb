require 'spec_helper'

describe Search::Reports::Items::API do
  let!(:namespace) { create(:namespace) }
  let(:user)       { create(:user) }
  let(:category)   { create(:reports_category_with_statuses) }

  describe 'GET /search/reports/items' do
    context 'sorting' do
      describe 'by user name' do
        let!(:users) { create_list(:user, 3) }

        let!(:items) do
          users.map do |u|
            create(:reports_item, category: category, user: u)
          end
        end

        let!(:valid_params) do
          {
            sort: 'user',
            order: 'asc'
          }
        end

        # TODO: this test is unstable
        # it 'returns the items on the correct order' do
        #   get '/search/reports/items', valid_params, auth(user)
        #
        #   returned_ids = parsed_body['reports'].map { |r| r['id'] }
        #
        #   ordered_ids = items.sort_by do |item|
        #     item.user.name
        #   end.map(&:id)
        #
        #   expect(returned_ids).to eq(ordered_ids)
        # end
      end

      describe 'by status title' do
        let!(:statuses) { create_list(:status, 3) }

        let!(:items) do
          statuses.map do |status|
            create(:reports_item, status: status)
          end
        end

        let!(:valid_params) do
          {
            sort: 'status',
            order: 'asc'
          }
        end

        it 'returns the items on the correct order' do
          get '/search/reports/items', valid_params, auth(user)

          returned_ids = parsed_body['reports'].map { |r| r['id'] }

          ordered_ids = items.sort_by do |item|
            item.status.title
          end.map(&:id)

          expect(returned_ids).to eq(ordered_ids)
        end
      end

      describe 'by category setting priority' do
        let!(:categories) do
          create_list(:reports_category_with_statuses, 3)
        end

        let!(:items) do
          categories.map do |c|
            create(:reports_item, category: c)
          end
        end

        let!(:valid_params) do
          {
            sort: 'priority',
            order: 'asc'
          }
        end

        before(:each) do
          items.each do |item|
            item.setting.update!(priority: [:high, :medium, :low].sample)
          end
        end

        it 'returns the items on the correct order' do
          get '/search/reports/items', valid_params, auth(user)

          returned_ids = parsed_body['reports'].map { |r| r['id'] }

          ordered_ids = items.sort_by do |item|
            item.setting.read_attribute(:priority)
          end.map(&:id)

          expect(returned_ids).to eq(ordered_ids)
        end
      end

      describe 'by category title' do
        let!(:categories) do
          create_list(:reports_category_with_statuses, 3)
        end

        let!(:items) do
          categories.map do |c|
            create(:reports_item, category: c)
          end
        end

        let!(:valid_params) do
          {
            sort: 'category',
            order: 'asc'
          }
        end

        it 'returns the items on the correct order' do
          get '/search/reports/items', valid_params, auth(user)

          returned_ids = parsed_body['reports'].map { |r| r['id'] }

          ordered_ids = items.sort_by do |item|
            item.category.title
          end.map(&:id)

          expect(returned_ids).to eq(ordered_ids)
        end
      end

      describe 'by group name' do
        let!(:groups) do
          create_list(:group, 3)
        end

        let!(:items) do
          groups.map do |g|
            create(:reports_item, assigned_group: g)
          end
        end

        let!(:valid_params) do
          {
            sort: 'assignment',
            order: 'asc'
          }
        end

        it 'returns the items on the correct order' do
          get '/search/reports/items', valid_params, auth(user)

          returned_ids = parsed_body['reports'].map { |r| r['id'] }

          ordered_ids = items.sort_by do |item|
            item.assigned_group.name
          end.map(&:id)

          expect(returned_ids).to eq(ordered_ids)
        end
      end

      describe 'by reporter name' do
        let!(:reporters) do
          create_list(:user, 3)
        end

        let!(:items) do
          reporters.map do |r|
            create(:reports_item, reporter: r)
          end
        end

        let!(:valid_params) do
          {
            sort: 'reporter',
            order: 'asc'
          }
        end

        it 'returns the items on the correct order' do
          get '/search/reports/items', valid_params, auth(user)

          returned_ids = parsed_body['reports'].map { |r| r['id'] }

          ordered_ids = items.sort_by do |item|
            item.reporter.name
          end.map(&:id)

          expect(returned_ids).to eq(ordered_ids)
        end
      end

      context 'report fields' do
        let!(:items) { create_list(:reports_item, 3) }

        let(:valid_params) do
          {
            order: 'asc'
          }
        end

        describe 'default order' do
          it 'returns the items on the correct order' do
            get '/search/reports/items', valid_params, auth(user)

            returned_ids = parsed_body['reports'].map { |r| r['id'] }

            ordered_ids = items.sort_by do |item|
              item.created_at
            end.map(&:id)

            expect(returned_ids).to eq(ordered_ids)
          end
        end

        describe 'by id' do
          let(:valid_params) do
            {
              sort: 'id',
              order: 'asc'
            }
          end

          it 'returns the items on the correct order' do
            get '/search/reports/items', valid_params, auth(user)

            returned_ids = parsed_body['reports'].map { |r| r['id'] }

            ordered_ids = items.sort_by do |item|
              item.id
            end.map(&:id)

            expect(returned_ids).to eq(ordered_ids)
          end
        end

        describe 'by updated_at' do
          let(:valid_params) do
            {
              sort: 'updated_at',
              order: 'asc'
            }
          end

          it 'returns the items on the correct order' do
            get '/search/reports/items', valid_params, auth(user)

            returned_ids = parsed_body['reports'].map { |r| r['id'] }

            ordered_ids = items.sort_by do |item|
              item.updated_at
            end.map(&:id)

            expect(returned_ids).to eq(ordered_ids)
          end
        end

        context 'by protocol' do
          let(:valid_params) do
            {
              sort: 'protocol',
              order: 'asc'
            }
          end

          it 'returns the items on the correct order' do
            get '/search/reports/items', valid_params, auth(user)

            returned_ids = parsed_body['reports'].map { |r| r['id'] }

            ordered_ids = items.sort_by do |item|
              item.protocol
            end.map(&:id)

            expect(returned_ids).to eq(ordered_ids)
          end
        end

        context 'by address and number' do
          let(:valid_params) do
            {
              sort: 'address',
              order: 'asc'
            }
          end

          it 'returns the items on the correct order' do
            get '/search/reports/items', valid_params, auth(user)

            returned_ids = parsed_body['reports'].map { |r| r['id'] }

            ordered_ids = items.sort_by do |item|
              "#{item.address}, #{item.number}"
            end.map(&:id)

            expect(returned_ids).to eq(ordered_ids)
          end
        end
      end
    end
  end
end
