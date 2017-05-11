require 'spec_helper'

describe Search::Reports::Items::API do
  let(:user) { create(:user) }

  describe 'GET /search/reports/:category_id/status/:status_id/items' do
    let(:category) { create(:reports_category_with_statuses) }
    let(:items) do
      create_list(:reports_item, 5, category: category)
    end

    let(:valid_params) do
      Oj.load <<-JSON
        {
          "address": "Abilio"
        }
      JSON
    end

    it 'returns the specified items' do
      desired_item = items.sample
      status = category.statuses.sample
      desired_item.update!(address: 'Rua Abilio Soares', status: status)

      get "/search/reports/#{category.id}/status/#{status.id}/items",
        valid_params, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body

      reports_ids = body['reports'].map do |r|
        r['id']
      end

      expect(reports_ids).to include(desired_item.id)
      items.delete(desired_item)
      expect(reports_ids).to_not include(items.map(&:id))
    end
  end

  describe 'GET /search/reports/items' do
    let(:category) { create(:reports_category_with_statuses) }

    context 'specifing the fields' do
      let!(:items) { create_list(:reports_item, 3, category: category) }

      it 'returns only specified fields' do
        get '/search/reports/items?return_fields=id,protocol,address,user.name&display_type=full', nil, auth(user)
        expect(response.status).to eq(200)

        body = parsed_body['reports']
        expect(body.first).to match(
          'id' => a_value,
          'protocol' => a_value,
          'address' => an_instance_of(String),
          'user' => {
            'name' => an_instance_of(String)
          }
        )
      end
    end

    describe 'by categories' do
      let!(:items) do
        create_list(:reports_item, 3, category: category)
      end
      let!(:wrong_items) do
        other_category = create(:reports_category_with_statuses)
        create_list(:reports_item, 3, category: other_category)
      end
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "reports_categories_ids": #{category.id}
          }
        JSON
      end

      it 'returns the correct items with the correct address' do
        get '/search/reports/items', valid_params, auth(user)

        returned_ids = parsed_body['reports'].map do |r|
          r['id']
        end

        expect(returned_ids).to match_array(items.map(&:id))
        expect(returned_ids).to_not match_array(wrong_items.map(&:id))
      end
    end

    describe 'by perimeters' do
      let(:perimeter) { create(:reports_perimeter) }
      let!(:items) do
        create_list(:reports_item, 3, perimeter: perimeter)
      end
      let!(:wrong_items) do
        create_list(:reports_item, 3)
      end

      let(:valid_params) do
        Oj.load <<-JSON
          {
            "reports_perimeters_ids": #{perimeter.id}
          }
        JSON
      end

      it 'returns the correct items with the correct address' do
        get '/search/reports/items', valid_params, auth(user)

        returned_ids = parsed_body['reports'].map do |r|
          r['id']
        end

        expect(returned_ids).to match_array(items.map(&:id))
        expect(returned_ids).to_not match_array(wrong_items.map(&:id))
      end
    end

    describe 'by groups' do
      let(:group) { create(:group) }
      let!(:items) do
        create_list(:reports_item, 3, assigned_group: group)
      end

      let!(:wrong_items) do
        create_list(:reports_item, 3)
      end

      let(:valid_params) do
        Oj.load <<-JSON
          {
            "groups_ids": #{group.id}
          }
        JSON
      end

      it 'returns the correct items with the correct address' do
        get '/search/reports/items', valid_params, auth(user)

        returned_ids = parsed_body['reports'].map do |r|
          r['id']
        end

        expect(returned_ids).to match_array(items.map(&:id))
        expect(returned_ids).to_not match_array(wrong_items.map(&:id))
      end
    end

    describe 'by users' do
      context 'only one user' do
        let(:user) { create(:user) }
        let!(:items) do
          create_list(:reports_item, 3, category: category, user: user)
        end
        let!(:wrong_items) do
          create_list(:reports_item, 3, category: category)
        end
        let(:valid_params) do
          Oj.load <<-JSON
          {
            "users_ids": #{user.id}
          }
          JSON
        end

        it 'returns the correct items from the correct user' do
          get '/search/reports/items', valid_params, auth(user)

          returned_ids = parsed_body['reports'].map do |r|
            r['id']
          end

          expect(returned_ids).to match_array(items.map(&:id))
          expect(returned_ids).to_not match_array(wrong_items.map(&:id))
        end
      end

      describe 'by multiple users' do
        let(:user) { create(:user) }
        let(:user2) { create(:user) }
        let!(:items) do
          other_category = create(:reports_category_with_statuses)
          create_list(:reports_item, 3, category: category, user: user) +
            create_list(:reports_item, 3, category: other_category, user: user)
        end
        let!(:wrong_items) do
          create_list(:reports_item, 3, category: category)
        end
        let(:valid_params) do
          Oj.load <<-JSON
          {
            "users_ids": "#{user.id},#{user2.id}"
          }
          JSON
        end

        it 'returns the correct items from the correct user' do
          get '/search/reports/items', valid_params, auth(user)

          returned_ids = parsed_body['reports'].map do |r|
            r['id']
          end

          expect(returned_ids).to match_array(items.map(&:id))
          expect(returned_ids).to_not match_array(wrong_items.map(&:id))
        end
      end
    end

    describe 'by reporters' do
      context 'only one reporter' do
        let(:reporter) { create(:user) }
        let!(:items) do
          create_list(:reports_item, 3, category: category, reporter: reporter)
        end
        let!(:wrong_items) do
          create_list(:reports_item, 3, category: category)
        end
        let(:valid_params) do
          Oj.load <<-JSON
          {
            "reporters_ids": #{reporter.id}
          }
          JSON
        end

        it 'returns the correct items from the correct user' do
          get '/search/reports/items', valid_params, auth(user)

          returned_ids = parsed_body['reports'].map do |r|
            r['id']
          end

          expect(returned_ids).to match_array(items.map(&:id))
          expect(returned_ids).to_not match_array(wrong_items.map(&:id))
        end
      end

      describe 'by multiple reporters' do
        let(:reporter) { create(:user) }
        let(:reporter2) { create(:user) }
        let!(:items) do
          other_category = create(:reports_category_with_statuses)
          create_list(:reports_item, 3, category: category, reporter: reporter) +
            create_list(:reports_item, 3, category: other_category, reporter: reporter2)
        end
        let!(:wrong_items) do
          create_list(:reports_item, 3, category: category)
        end
        let(:valid_params) do
          Oj.load <<-JSON
          {
            "reporters_ids": "#{reporter.id},#{reporter2.id}"
          }
          JSON
        end

        it 'returns the correct items from the correct user' do
          get '/search/reports/items', valid_params, auth(user)

          returned_ids = parsed_body['reports'].map do |r|
            r['id']
          end

          expect(returned_ids).to match_array(items.map(&:id))
          expect(returned_ids).to_not match_array(wrong_items.map(&:id))
        end
      end
    end

    describe 'by statuses' do
      let!(:items) do
        create_list(:reports_item, 3, category: category)
      end
      let!(:wrong_items) do
        new_status = create(:status)

        create(:reports_status_category, status: new_status, category: category)

        items = create_list(:reports_item, 3, category: category)
        items.each do |item|
          Reports::UpdateItemStatus.new(item).update_status!(new_status)
        end

        items
      end
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "statuses_ids": "#{items.first.reports_status_id}"
          }
        JSON
      end

      it 'returns the correct items with the correct address' do
        get '/search/reports/items', valid_params, auth(user)

        returned_ids = parsed_body['reports'].map do |r|
          r['id']
        end

        expect(returned_ids).to match_array(items.map(&:id))
        expect(returned_ids).to_not match_array(wrong_items.map(&:id))
      end
    end

    describe 'by address' do
      let(:items) do
        create_list(:reports_item, 3, category: category)
      end

      let(:valid_params) do
        Oj.load <<-JSON
          {
            "address": "abilio"
          }
        JSON
      end

      it 'returns the correct items with the correct address' do
        correct_item = items.sample
        correct_item.update(address: 'Rua Abilio Soares, 140')

        get '/search/reports/items', valid_params, auth(user)
        expect(parsed_body['reports'].first['id']).to eq(correct_item.id)
      end
    end

    describe 'by district' do
      let(:items) do
        create_list(:reports_item, 3, category: category)
      end

      let(:valid_params) do
        Oj.load <<-JSON
          {
            "address": "centro"
          }
        JSON
      end

      it 'returns the correct items with the correct address' do
        correct_item = items.sample
        correct_item.update(district: 'Centro')

        get '/search/reports/items', valid_params, auth(user)
        expect(parsed_body['reports'].first['id']).to eq(correct_item.id)
      end
    end

    describe 'by postal code' do
      let(:items) do
        create_list(:reports_item, 3, category: category)
      end

      let(:valid_params) do
        Oj.load <<-JSON
          {
            "address": "12345-000"
          }
        JSON
      end

      it 'returns the correct items with the correct address' do
        correct_item = items.sample
        correct_item.update(postal_code: '12345-000')

        get '/search/reports/items', valid_params, auth(user)
        expect(parsed_body['reports'].first['id']).to eq(correct_item.id)
      end
    end

    describe 'by overdue' do
      let(:items) do
        create_list(:reports_item, 3, category: category)
      end
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "overdue": true
          }
        JSON
      end

      it 'returns the correct items with the correct address' do
        correct_item = items.sample
        correct_item.update(overdue: true)

        get '/search/reports/items', valid_params, auth(user)
        expect(parsed_body['reports'].map { |r| r['id'] }).to eq([correct_item.id])
      end
    end

    describe 'by query' do
      let!(:items) do
        create_list(:reports_item, 5, category: category)
      end
      let!(:correct_items) do
        user = create(:user, name: 'crazybar')
        item = items.sample
        items.delete(item)
        item.update(user_id: user.id)

        item2 = items.sample
        items.delete(item2)
        item2.update(address: 'crazybar do naldo')

        [item, item2]
      end
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "query": "crazybar"
          }
        JSON
      end

      it 'returns the correct items with the correct address' do
        get '/search/reports/items', valid_params, auth(user)
        expect(parsed_body['reports'].map do |r|
          r['id']
        end).to match_array(correct_items.map(&:id))
      end
    end

    describe 'by user document' do
      let!(:items) do
        create_list(:reports_item, 5, category: category)
      end
      let!(:correct_items) do
        user = create(:user, document: '123456789')
        item = items.sample
        items.delete(item)
        item.update(user_id: user.id)

        item2 = items.sample
        items.delete(item2)
        user2 = create(:user, document: '12123456')
        item2.update(user_id: user2.id)

        [item, item2]
      end
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "user_document": "1234"
          }
        JSON
      end

      it 'returns the correct items with the correct document' do
        get '/search/reports/items', valid_params, auth(user)

        expected_ids = parsed_body['reports'].map { |r| r['id'] }

        expect(expected_ids).to match_array(correct_items.map(&:id))
      end
    end

    describe 'by address or position' do
      let(:items) do
        create_list(:reports_item, 3, category: category)
      end
      let(:latitude) { -23.5505200 }
      let(:longitude) { -46.6333090 }
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "address": "abilio",
            "position": {
              "latitude": #{latitude},
              "longitude": #{longitude},
              "distance": 1000
            }
          }
        JSON
      end

      it 'returns the correct items with address, position or both' do
        items.each do |item|
          item.update(
            position: Reports::Item.rgeo_factory.point(-1, 0)
          )
        end

        correct_item_1 = items.first
        correct_item_1.update(address: 'Rua Abilio Soares, 140')

        correct_item_2 = items.last
        correct_item_2.update(
          position: Reports::Item.rgeo_factory.point(longitude, latitude)
        )

        get '/search/reports/items', valid_params, auth(user)
        expect(parsed_body['reports'].map do
          |r| r['id']
        end).to match_array([correct_item_1.id, correct_item_2.id])
      end
    end

    describe 'with clusterization active' do
      let(:items) do
        create_list(:reports_item, 3, category: category)
      end
      let(:latitude) { -23.5505200 }
      let(:longitude) { -46.6333090 }
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "position": {
              "latitude": #{latitude},
              "longitude": #{longitude},
              "distance": 1000
            },
            "clusterize": true,
            "zoom": 1
          }
        JSON
      end

      before do
        items.each do |item|
          item.update(
            position: Reports::Item.rgeo_factory.point(longitude, latitude)
          )
        end
      end

      it 'returns clusterized options' do
        get '/search/reports/items', valid_params, auth(user)
        body = parsed_body

        expect(body['clusters'].size).to eq(1)
        expect(response.header['Total']).to eq('3')

        cluster = body['clusters'].first

        expect(cluster['position']).to_not be_empty
        expect(cluster['count']).to eq(3)
        expect(cluster['categories_ids']).to be_present
      end
    end

    describe 'assigned to groups that user belongs' do
      let(:items) do
        create_list(:reports_item, 3, category: category)
      end
      let(:group) { create(:group) }
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "assigned_to_my_group": true
          }
        JSON
      end

      before do
        user.groups << group
        user.save!
      end

      it 'returns the correct items assigned to the group' do
        correct_item = items.sample
        correct_item.update(assigned_group: group)

        get '/search/reports/items', valid_params, auth(user)
        expect(response.status).to eq(200)
        expect(parsed_body['reports'].map { |r| r['id'] }).to eq([correct_item.id])
      end
    end

    describe 'assigned to the requesting user' do
      let(:items) do
        create_list(:reports_item, 3, category: category)
      end
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "assigned_to_me": true
          }
        JSON
      end

      it 'returns the correct items assigned to the group' do
        correct_item = items.sample
        correct_item.update(assigned_user: user)

        get '/search/reports/items', valid_params, auth(user)
        expect(response.status).to eq(200)
        expect(parsed_body['reports'].map { |r| r['id'] }).to eq([correct_item.id])
      end
    end

    describe 'reports with offensive flags' do
      let(:items) do
        create_list(:reports_item, 3, category: category)
      end
      let(:offensive_item) { items.sample }

      before do
        Reports::OffensiveFlag.create(
          user: user,
          item: offensive_item
        )
      end

      let(:valid_params) do
        Oj.load <<-JSON
          {
            "flagged_offensive": true
          }
        JSON
      end

      it 'returns the correct items marked as offensive' do
        get '/search/reports/items', valid_params, auth(user)
        expect(response.status).to eq(200)
        expect(parsed_body['reports'].map { |r| r['id'] }).to eq([offensive_item.id])
      end
    end

    context 'reports marked offensive' do
      let!(:offensive_items) do
        create_list(:reports_item, 3, :offensive, category: category)
      end
      let!(:items) do
        create_list(:reports_item, 3, category: category)
      end
      let(:group) { create(:group) }

      context "user can't manage category" do
        before do
          group.permission.update!(reports_items_read_public: [category.id])

          user.groups = [group]
          user.save!
        end

        it "won't return those items" do
          get '/search/reports/items', nil, auth(user)
          expect(response.status).to eq(200)
          expect(parsed_body['reports'].map { |r| r['id'] }).to match_array(items.map(&:id))
        end

        context 'user can edit items in category', broken: true do
          before do
            group.permission.update!(reports_items_edit: [category.id])

            user.groups = [group]
            user.save!
          end

          it 'returns offensive items' do
            get '/search/reports/items', nil, auth(user)
            expect(response.status).to eq(200)
            expect(parsed_body['reports'].map { |r| r['id'] }).to match_array(items.map(&:id) + offensive_items.map(&:id))
          end
        end
      end
    end

    context 'filter for notifications' do
      describe '`with_notification` filter' do
        let!(:correct_items) do
          create_list(:reports_item, 3, category: category)
        end
        let!(:wrong_items) do
          create_list(:reports_item, 3, category: category)
        end

        let(:params) do
          {
            with_notifications: true
          }
        end

        before do
          correct_items.each do |correct_item|
            create(:reports_notification, item: correct_item)
          end
        end

        it 'returns the correct items' do
          get '/search/reports/items', params, auth(user)
          expect(response.status).to eq(200)

          expect(parsed_body['reports'].map do
            |r| r['id']
          end).to match_array(correct_items.map(&:id))
        end
      end

      describe 'days_since_last_notification filter' do
        let!(:correct_items) do
          create_list(:reports_item, 3, category: category)
        end
        let!(:wrong_items) do
          create_list(:reports_item, 3, category: category)
        end
        let(:group) { create(:group) }
        let(:params) do
          {
            days_since_last_notification: {
              begin: 1,
              end: 10
            }
          }
        end

        before do
          correct_items.each_with_index do |correct_item, i|
            create(:reports_notification, item: correct_item, created_at: ((i + 1) * 2).days.ago)
          end

          wrong_items.each do |wrong_item|
            create(:reports_notification, item: wrong_item, created_at: 20.days.ago)
          end
        end

        it 'returns the correct items' do
          get '/search/reports/items', params, auth(user)
          expect(response.status).to eq(200)
          expect(parsed_body['reports'].map { |r| r['id'] }).to match_array(correct_items.map(&:id))
        end
      end

      describe '`days_for_last_notification_deadline` filter' do
        let!(:correct_items) do
          create_list(:reports_item, 3, category: category)
        end
        let!(:wrong_items) do
          create_list(:reports_item, 3, category: category)
        end
        let!(:wrong_items_overdue) do
          create_list(:reports_item, 3, category: category)
        end
        let(:group) { create(:group) }
        let(:params) do
          {
            days_for_last_notification_deadline: {
              begin: 2,
              end: 10,
            }
          }
        end

        before do
          correct_items.each_with_index do |correct_item, i|
            create(:reports_notification, item: correct_item, overdue_at: ((i + 1) * 3).days.from_now)
          end

          wrong_items.each do |wrong_item|
            create(:reports_notification, item: wrong_item, overdue_at: 15.days.from_now)
          end

          wrong_items_overdue.each do |wrong_item|
            create(:reports_notification, item: wrong_item, overdue_at: 2.days.ago)
          end
        end

        it 'returns the correct items' do
          get '/search/reports/items', params, auth(user)
          expect(response.status).to eq(200)
          expect(parsed_body['reports'].map { |r| r['id'] }).to match_array(correct_items.map(&:id))
        end
      end

      describe '`minimum_notification_number` filter' do
        let!(:correct_items) do
          create_list(:reports_item, 3, category: category)
        end
        let!(:wrong_items) do
          create_list(:reports_item, 3, category: category)
        end
        let(:group) { create(:group) }
        let(:params) do
          {
            minimum_notification_number: 3
          }
        end

        before do
          correct_items.each do |correct_item|
            create_list(:reports_notification, 3, item: correct_item)
          end

          wrong_items.each do |wrong_item|
            create(:reports_notification, item: wrong_item)
          end
        end

        it 'returns the correct items' do
          get '/search/reports/items', params, auth(user)
          expect(response.status).to eq(200)
          expect(parsed_body['reports'].map { |r| r['id'] }).to match_array(correct_items.map(&:id))
        end
      end

      describe '`days_for_overdue_notification` filter' do
        let!(:correct_items) do
          create_list(:reports_item, 3, category: category)
        end
        let!(:wrong_items) do
          create_list(:reports_item, 3, category: category)
        end
        let!(:wrong_items_overdue) do
          create_list(:reports_item, 3, category: category)
        end
        let(:group) { create(:group) }
        let(:params) do
          {
            days_for_overdue_notification: {
              begin: 2,
              end: 10
            }
          }
        end

        before do
          correct_items.each_with_index do |correct_item, i|
            create(:reports_notification, item: correct_item, overdue_at: ((i + 1) * 3).days.ago)
          end

          wrong_items.each do |wrong_item|
            create(:reports_notification, item: wrong_item, overdue_at: 15.days.ago)
          end

          wrong_items_overdue.each do |wrong_item|
            create(:reports_notification, item: wrong_item, overdue_at: 1.days.from_now)
          end
        end

        it 'returns the correct items' do
          get '/search/reports/items', params, auth(user)
          expect(response.status).to eq(200)
          expect(parsed_body['reports'].map { |r| r['id'] }).to match_array(correct_items.map(&:id))
        end
      end
    end

    describe 'return only reports item from active categories' do
      let(:marked_category) { create(:reports_category_with_statuses, :deleted) }
      let!(:item)           { create(:reports_item, category: marked_category) }

      it 'return the correct items' do
        get '/search/reports/items', nil, auth(user)

        expect(response.status).to eq(200)

        returned_ids = parsed_body['reports'].map { |r| r['id'] }

        expect(returned_ids).to_not include(item.id)
      end
    end
  end
end
