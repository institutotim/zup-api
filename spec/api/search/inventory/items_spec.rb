require 'spec_helper'

describe Search::Inventory::Items::API do
  let(:user) { create(:user) }

  describe 'GET /search/inventory/items' do
    let(:category) { create(:inventory_category_with_sections) }

    context 'specifing the fields' do
      let!(:items) { create_list(:inventory_item, 3, category: category) }

      it 'returns only specified fields' do
        get '/search/inventory/items?return_fields=id,title,address,user.name&display_type=full', nil, auth(user)
        expect(response.status).to eq(200)

        body = parsed_body['items']
        expect(body.first).to match(
          'id' => a_value,
          'title' => an_instance_of(String),
          'address' => an_instance_of(String),
          'user' => {
            'name' => an_instance_of(String)
          }
        )
      end
    end

    context 'filtered by permission' do
      let!(:items) { create_list(:inventory_item, 3, category: category) }
      let!(:other_category) { create(:inventory_category_with_sections) }
      let!(:other_items) { create_list(:inventory_item, 2, category: other_category) }
      let!(:group) { create(:group) }

      before do
        group.permission.inventories_items_read_only = [other_category.id]
        group.save!
        user.groups = [group]
        user.save!
      end

      it 'only can see the category it has the permission' do
        get '/search/inventory/items?display_type=basic&order=desc&page=1&per_page=30&sort=title', nil, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body['items'].size).to eq(2)
        expect(body['items'].map do |i|
          i['id']
        end).to match_array(other_items.map(&:id))
      end
    end

    context 'by address' do
      let(:items) do
        create_list(:inventory_item, 10, category: category)
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

        get '/search/inventory/items', valid_params, auth(user)
        expect(parsed_body['items'].first['id']).to eq(correct_item.id)
      end
    end

    context 'by query' do
      let!(:items) do
        create_list(:inventory_item, 5, category: category)
      end
      let!(:correct_items) do
        item = items.sample
        items.delete(item)
        item.update(title: 'Tree 123456')

        item2 = items.sample
        items.delete(item2)
        item2.update(address: '123456 ol street')

        item3 = items.sample
        items.delete(item3)
        item3.update(sequence: 123456)

        [item, item2, item3]
      end
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "query": "123456"
          }
        JSON
      end

      it 'returns the correct items' do
        get '/search/inventory/items', valid_params, auth(user)
        expect(parsed_body['items'].map do |r|
          r['id']
        end).to match_array(correct_items.map(&:id))
      end
    end

    context 'by user ids' do
      let!(:user) { create(:user) }
      let!(:user2) { create(:user) }
      let!(:items) do
        create_list(:inventory_item, 3, category: category)
      end
      let!(:correct_items) do
        item = items.sample
        items.delete(item)
        item.update(user_id: user.id)

        item2 = items.sample
        items.delete(item2)
        item2.update(user_id: user2.id)

        [item, item2]
      end
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "users_ids": "#{user.id},#{user2.id}"
          }
        JSON
      end

      before do
        get '/search/inventory/items', valid_params, auth(user)
      end

      it 'returns the correct items with the correct address' do
        expect(parsed_body['items'].map do |i|
          i['id']
        end).to match_array(correct_items.map(&:id))
      end
    end

    context 'by title' do
      let(:items) do
        create_list(:inventory_item, 10, category: category)
      end
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "title": "torta"
          }
        JSON
      end

      it 'returns the correct items with the correct address' do
        correct_item = items.sample
        correct_item.update(title: 'Árvore torta')

        get '/search/inventory/items', valid_params, auth(user)
        expect(parsed_body['items'].first['id']).to eq(correct_item.id)
      end
    end

    context 'by multiple positions' do
      let(:items) do
        create_list(:inventory_item, 10, category: category)
      end
      let(:latitude) { -23.5505200 }
      let(:longitude) { -46.6333090 }
      let(:latitude2) { -20.5505200 }
      let(:longitude2) { -20.6333090 }

      let(:valid_params) do
        Oj.load <<-JSON
          {
            "address": "abilio",
            "position": {
              "0": {
                "latitude": #{latitude},
                "longitude": #{longitude},
                "distance": 1000
              },
              "1": {
                "latitude": #{latitude2},
                "longitude": #{longitude2},
                "distance": 1000
              }
            }
          }
        JSON
      end

      it 'returns the correct items with both positions args' do
        items.each do |item|
          item.update_attribute(
            :position, Reports::Item.rgeo_factory.point(-1, -1)
          )
        end

        correct_item_1 = items.first
        correct_item_1.update_attribute(
          :position, Reports::Item.rgeo_factory.point(longitude, latitude)
        )

        correct_item_2 = items.last
        correct_item_2.update_attribute(
          :position, Reports::Item.rgeo_factory.point(longitude2, latitude2)
        )

        get '/search/inventory/items', valid_params, auth(user)
        expect(parsed_body['items'].map do
          |r| r['id']
        end).to match_array([correct_item_1.id, correct_item_2.id])
      end
    end

    context 'by address or position' do
      let(:items) do
        create_list(:inventory_item, 10, category: category)
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
          item.update_attribute(
            :position, Reports::Item.rgeo_factory.point(-1, -1)
          )
        end

        correct_item_1 = items.first
        correct_item_1.update(address: 'Rua Abilio Soares, 140')

        correct_item_2 = items.last
        correct_item_2.update_attribute(
          :position, Reports::Item.rgeo_factory.point(longitude, latitude)
        )

        get '/search/inventory/items', valid_params, auth(user)
        expect(parsed_body['items'].map do
          |r| r['id']
        end).to match_array([correct_item_1.id, correct_item_2.id])
      end
    end

    context 'with clusterization active' do
      let(:items) do
        create_list(:inventory_item, 3, category: category)
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
            "zoom": 1,
            "clusterize": true
          }
        JSON
      end

      before do
        items.each do |item|
          item.update_attribute(
            :position, Reports::Item.rgeo_factory.point(longitude, latitude)
          )
        end
      end

      it 'returns clusterized options' do
        get '/search/inventory/items', valid_params, auth(user)
        body = parsed_body

        expect(body['clusters'].size).to eq(1)
        expect(response.header['Total']).to eq('3')

        cluster = body['clusters'].first

        expect(cluster['position']).to_not be_empty
        expect(cluster['count']).to eq(3)
        expect(cluster['categories_ids']).to be_present
      end
    end

    context 'by status' do
      let(:status) { create(:inventory_status, category: category) }
      let(:wrong_status) { create(:inventory_status, category: category) }
      let!(:items) do
        create_list(:inventory_item, 3, category: category, status: status)
      end
      let!(:wrong_items) do
        create_list(:inventory_item, 3, category: category, status: wrong_status)
      end
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "inventory_statuses_ids": "#{status.id}"
          }
        JSON
      end

      it 'returns the correct items with the correct address' do
        get '/search/inventory/items', valid_params, auth(user)
        expect(parsed_body['items'].map do |i|
          i['id']
        end).to match_array(items.map(&:id))
      end
    end

    context 'by created_at' do
      let!(:items) do
        create_list(:inventory_item, 3, category: category)
      end
      let!(:correct_item) do
        item = items.sample
        item.update(created_at: DateTime.new(2014, 1, 10))
        item
      end
      let!(:wrong_items) do
        items.delete(correct_item)
      end
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "created_at": {
              "begin": "#{Date.new(2014, 1, 9).iso8601}",
              "end": "#{Date.new(2014, 1, 13).iso8601}"
            }
          }
        JSON
      end

      before do
        get '/search/inventory/items', valid_params, auth(user)
      end

      it 'returns the correct item' do
        expect(parsed_body['items'].map do |i|
          i['id']
        end).to eq([correct_item.id])
      end
    end

    context 'by field content' do
      let!(:field) { create(:inventory_field, section: category.sections.sample) }

      context 'using the lesser_than' do
        let!(:items) do
          create_list(:inventory_item, 3, category: category)
        end
        let!(:correct_item) do
          item = items.sample
          item.data.find_by(field: field).update!(content: 20)
          item
        end
        let!(:wrong_items) do
          items.delete(correct_item)
          items.each do |item|
            item.data.find_by(field: field).update!(content: 30)
          end
        end
        let(:valid_params) do
          Oj.load <<-JSON
          {
            "fields": {
              "#{field.id}": {
                "lesser_than": 30
              }
            }
          }
          JSON
        end

        before do
          field.update(kind: 'integer')
          get '/search/inventory/items', valid_params, auth(user)
        end

        it 'returns the correct item' do
          expect(parsed_body['items'].map do |i|
            i['id']
          end).to eq([correct_item.id])
        end
      end

      context 'using the greater_than' do
        let!(:items) do
          create_list(:inventory_item, 3, category: category)
        end
        let!(:correct_item) do
          item = items.sample
          item.data.find_by(field: field).update!(content: 30)
          item
        end
        let!(:wrong_items) do
          items.delete(correct_item)
          items.each do |item|
            item.data.find_by(field: field).update!(content: 20)
          end
        end
        let(:valid_params) do
          Oj.load <<-JSON
          {
            "fields": {
              "#{field.id}": {
                "greater_than": 29
              }
            }
          }
          JSON
        end

        before do
          field.update(kind: 'integer')
          get '/search/inventory/items', valid_params, auth(user)
        end

        it 'returns the correct item' do
          expect(parsed_body['items'].map do |i|
            i['id']
          end).to eq([correct_item.id])
        end
      end

      context 'using equal_to' do
        context 'using input field' do
          let!(:items) do
            create_list(:inventory_item, 3, category: category)
          end
          let!(:correct_item) do
            item = items.sample
            item.data.find_by(field: field).update!(content: 30)
            item
          end
          let!(:wrong_items) do
            items.delete(correct_item)
            items.each do |item|
              item.data.find_by(field: field).update!(content: 20)
            end
          end
          let(:valid_params) do
            Oj.load <<-JSON
            {
              "fields": {
                "#{field.id}": {
                  "equal_to": 30
                }
              }
            }
            JSON
          end

          before do
            field.update(kind: 'integer')
            get '/search/inventory/items', valid_params, auth(user)
          end

          it 'returns the correct item' do
            expect(parsed_body['items'].map do |i|
              i['id']
            end).to eq([correct_item.id])
          end
        end

        context 'using input with option selected' do
          let!(:items) do
            create_list(:inventory_item, 3, category: category)
          end
          let(:correct_option) do
            create(:inventory_field_option, field: field, value: 30)
          end
          let!(:correct_item) do
            item = items.sample
            item.data.find_by(field: field).update!(inventory_field_option_ids: [correct_option.id])
            item
          end
          let(:wrong_option) do
            create(:inventory_field_option, field: field, value: 20)
          end
          let!(:wrong_items) do
            items.delete(correct_item)
            items.each do |item|
              item.data.find_by(field: field).update!(inventory_field_option_ids: [wrong_option.id])
            end
          end
          let(:valid_params) do
            Oj.load <<-JSON
              {
                "fields": {
                  "#{field.id}": {
                    "equal_to": "30"
                  }
                },
                "sort": "title",
                "order": "asc"
              }
            JSON
          end

          before do
            field.update(kind: 'radio')
            get '/search/inventory/items?only=id', valid_params, auth(user)
          end

          it 'returns the correct item' do
            expect(parsed_body['items'].map do |i|
              i['id']
            end).to eq([correct_item.id])
          end
        end

        context 'should not return repeated results' do
          let!(:options) do
            [
              create(:inventory_field_option, field: field, value: 'Opção 1'),
              create(:inventory_field_option, field: field, value: 'Opção 2')
            ]
          end
          let!(:item) do
            item = create(:inventory_item, category: category)
            item.data.find_by(field: field).update!(inventory_field_option_ids: options.map(&:id))
            item
          end
          let(:valid_params) do
            Oj.load <<-JSON
            {
              "fields": {
                "#{field.id}": {
                  "includes": ["Opção 1"]
                }
              }
            }
            JSON
          end

          before do
            field.update(kind: 'checkbox')
            get '/search/inventory/items', valid_params, auth(user)
          end

          it 'returns the correct item' do
            expect(parsed_body['items'].map do |i|
              i['id']
            end).to eq([item.id])
          end
        end
      end

      context 'using multiple filters' do
        let!(:field2) { create(:inventory_field, section: category.sections.sample) }
        let!(:field3) { create(:inventory_field, section: category.sections.sample) }
        let!(:items) do
          create_list(:inventory_item, 3, category: category)
        end
        let!(:correct_item) do
          item = items.sample
          item.data.find_by(field: field).update!(content: 50)
          item.data.find_by(field: field2).update!(content: 'Sim')
          item.data.find_by(field: field3).update!(content: 'Não')
          item
        end
        let!(:wrong_items) do
          items.delete(correct_item)
          items.each do |item|
            item.data.find_by(field: field).update!(content: 120)
            item.data.find_by(field: field2).update!(content: 'Não')
            item.data.find_by(field: field3).update!(content: 'Sim')
          end
        end
        let(:valid_params) do
          Oj.load <<-JSON
            {
              "fields": {
                "#{field.id}": {
                  "greater_than": 30,
                  "lesser_than": 100
                },
                "#{field2.id}": {
                  "equal_to": "Sim"
                },
                "#{field3.id}": {
                  "equal_to": "Não"
                }
              },
              "sort": "title",
              "order": "asc"
            }
          JSON
        end

        before do
          field.update(kind: 'integer')
          get '/search/inventory/items', valid_params, auth(user)
        end

        it 'returns the correct item' do
          expect(parsed_body['items'].map do |i|
            i['id']
          end).to eq([correct_item.id])
        end
      end

      context 'using different' do
        let!(:items) do
          create_list(:inventory_item, 3, category: category)
        end
        let!(:correct_item) do
          item = items.sample
          item.data.find_by(field: field).update!(content: 30)
          item
        end
        let!(:wrong_items) do
          items.delete(correct_item)
          items.each do |item|
            item.data.find_by(field: field).update!(content: 20)
          end
        end
        let(:valid_params) do
          Oj.load <<-JSON
          {
            "fields": {
              "#{field.id}": {
                "different": 20
              }
            }
          }
          JSON
        end

        before do
          field.update(kind: 'integer')
          get '/search/inventory/items', valid_params, auth(user)
        end

        it 'returns the correct item' do
          expect(parsed_body['items'].map do |i|
            i['id']
          end).to eq([correct_item.id])
        end
      end

      context 'using like' do
        let!(:items) do
          create_list(:inventory_item, 3, category: category)
        end
        let!(:correct_item) do
          item = items.sample
          item.data.find_by(field: field).update!(content: 'correct_test')
          item
        end
        let!(:wrong_items) do
          items.delete(correct_item)
          items.each do |item|
            item.data.find_by(field: field).update!(content: 'wrong_test')
          end
        end
        let(:valid_params) do
          Oj.load <<-JSON
          {
            "fields": {
              "#{field.id}": {
                "like": "correct"
              }
            }
          }
          JSON
        end

        before do
          get '/search/inventory/items', valid_params, auth(user)
        end

        it 'returns the correct item' do
          expect(parsed_body['items'].map do |i|
            i['id']
          end).to eq([correct_item.id])
        end
      end

      context 'using includes' do
        context 'using input with option selected' do
          let!(:field) { create(:inventory_field, section: category.sections.sample, kind: 'checkbox') }
          let!(:items) do
            create_list(:inventory_item, 3, category: category)
          end
          let(:correct_options) do
            [
              create(:inventory_field_option, value: 'this', field: field),
              create(:inventory_field_option, value: 'is', field: field),
              create(:inventory_field_option, value: 'a test', field: field)
            ]
          end
          let!(:correct_items) do
            item = items.sample
            items.delete(item)
            item.data.find_by(field: field).update!(inventory_field_option_ids: correct_options.map(&:id))

            item2 = items.sample
            items.delete(item2)
            item2.data.find_by(field: field).update!(inventory_field_option_ids: correct_options[1..3].map(&:id))

            [item, item2]
          end
          let(:wrong_options) do
            [
              create(:inventory_field_option, field: field, value: 'crazy stuff')
            ]
          end
          let!(:wrong_items) do
            items.each do |item|
              item.data.find_by(field: field).update!(inventory_field_option_ids: wrong_options.map(&:id))
            end
          end
          let(:valid_params) do
            Oj.load <<-JSON
              {
                "fields": {
                  "#{field.id}": {
                    "includes": {
                      "0": "is",
                      "1": "a test"
                    }
                  }
                }
              }
            JSON
          end

          before do
            get '/search/inventory/items', valid_params, auth(user)
          end

          it 'returns the correct item' do
            expect(parsed_body['items'].map do |i|
              i['id']
            end).to match_array(correct_items.map(&:id))
          end
        end
      end

      context 'using excludes' do
        context 'using input with option selected' do
          let!(:field) { create(:inventory_field, section: category.sections.sample, kind: 'checkbox') }
          let!(:items) do
            create_list(:inventory_item, 3, category: category)
          end
          let(:correct_options) do
            [
              create(:inventory_field_option, value: 'pretty', field: field),
              create(:inventory_field_option, value: 'crazy', field: field),
              create(:inventory_field_option, value: 'stuff', field: field),
              create(:inventory_field_option, value: 'another', field: field)
            ]
          end
          let!(:correct_items) do
            item = items.sample
            items.delete(item)
            item.data.find_by(field: field).update!(inventory_field_option_ids: correct_options.map(&:id))

            item2 = items.sample
            items.delete(item2)
            item2.data.find_by(field: field).update!(inventory_field_option_ids: correct_options[1..3].map(&:id))

            [item, item2]
          end
          let(:wrong_options) do
            [
              field.field_options.reload.find_by(value: 'crazy'),
              create(:inventory_field_option, field: field, value: 'is'),
              create(:inventory_field_option, field: field, value: 'a test')
            ]
          end
          let!(:wrong_items) do
            items.each do |item|
              item.data.find_by(field: field).update!(inventory_field_option_ids: wrong_options.map(&:id))
            end
          end
          let(:valid_params) do
            Oj.load <<-JSON
            {
              "fields": {
                "#{field.id}": {
                  "excludes": {
                    "0": "is",
                    "1": "a test"
                  }
                }
              }
            }
            JSON
          end

          before do
            get '/search/inventory/items', valid_params, auth(user)
          end

          it 'returns the correct item' do
            expect(parsed_body['items'].map do |i|
              i['id']
            end).to match_array(correct_items.map(&:id))
          end
        end
      end
    end
  end
end
