require 'spec_helper'

describe Inventory::Items::API do
  let(:user) { create(:user) }

  context 'POST /inventory/categories/:id/items' do
    let(:category) { create(:inventory_category_with_sections) }
    let(:status) { create(:inventory_status, category: category) }
    let(:valid_params) do
      Oj.load <<-JSON
        {
          "inventory_status_id": #{status.id},
          "data": {}
        }
      JSON
    end

    it 'creates the item object' do
      category.fields.each do |field|
        if field.kind == 'text'
          valid_params['data'][field.id] = 'Test'
        else
          valid_params['data'][field.id] = 0.0
        end
      end

      post "/inventory/categories/#{category.id}/items", valid_params, auth(user)

      expect(response.status).to eq(201)
      expect(parsed_body).to include('message')

      expect(category.items.last).to_not be_nil
      expect(category.items.last.data).to_not be_empty
      expect(category.items.last.data.joins(:field).where(inventory_fields: { kind: 'text' }).first.content).to eq('Test')
      expect(category.items.last.user).to eq(user)
      expect(category.items.last.status).to eq(status)
    end

    it 'creates the item object with images' do
      images_field_id = category.sections.last.fields.create(
        title: 'Imagens',
        kind: 'images',
        position: 0
      ).id

      fields = category.fields.order('id ASC')
      item_params = []

      fields.each do |field|
        unless field.kind == 'images'
          valid_params['data'][field.id] = 'Rua do Banco'
        else
          valid_params['data'][field.id] = [
            {
              content: Base64.encode64(fixture_file_upload("#{Application.config.root}/spec/fixtures/images/valid_report_item_photo.jpg").read)
            },
            {
              content: Base64.encode64(fixture_file_upload("#{Application.config.root}/spec/fixtures/images/valid_report_item_photo.jpg").read)
            }
          ]
        end
      end

      post "/inventory/categories/#{category.id}/items", valid_params, auth(user)
      expect(response.status).to eq(201)
      body = parsed_body

      expect(body).to include('message')

      image_data = category.items.last.data.find_by(inventory_field_id: images_field_id)
      expect(category.items.last).to_not be_nil
      expect(category.items.last.data).to_not be_empty
      expect(image_data.content).to be_kind_of(Array)
      expect(category.items.last.user).to_not be_nil
    end

    it 'creates the item object with attachments' do
      attachments_field_id = category.sections.last.fields.create(
        title: 'Anexos',
        kind: 'attachments',
        position: 0
      ).id

      fields = category.fields.order('id ASC')
      item_params = []

      fields.each do |field|
        unless field.kind == 'attachments'
          valid_params['data'][field.id] = 'Rua do Banco'
        else
          valid_params['data'][field.id] = [
            {
              file_name: 'test.docx',
              content: Base64.encode64(fixture_file_upload("#{Application.config.root}/spec/fixtures/images/valid_report_item_photo.jpg").read)
            },
            {
              file_name: 'test2.docx',
              content: Base64.encode64(fixture_file_upload("#{Application.config.root}/spec/fixtures/images/valid_report_item_photo.jpg").read)
            }
          ]
        end
      end

      post "/inventory/categories/#{category.id}/items", valid_params, auth(user)
      expect(response.status).to eq(201)
      body = parsed_body

      expect(body).to include('message')

      attachment_data = category.items.last.data.find_by(inventory_field_id: attachments_field_id)
      expect(category.items.last).to_not be_nil
      expect(category.items.last.data).to_not be_empty
      expect(attachment_data.content).to be_kind_of(Array)
      expect(category.items.last.user).to_not be_nil
    end

    it "doesn't allow to miss required fields" do
      category.fields.each do |field|
        valid_params['data'][field.id] = 'Test'
      end

      required_field = create(:inventory_field, section: category.sections.sample, required: true)
      user.groups.first.permission.update!(inventory_fields_can_edit: [required_field.id])
      last_item = category.items.last

      post "/inventory/categories/#{category.id}/items", valid_params, auth(user)
      expect(response.status).to eq(400)
      expect(parsed_body).to include('error')
      expect(category.items.reload.last).to eq(last_item)
    end

    it 'accepts array as data' do
      category.fields.each do |field|
        valid_params['data'][field.id] = 'Test'
      end

      checkbox_field = create(:inventory_field, section: category.sections.sample, kind: 'checkbox')
      option1 = create(:inventory_field_option, field: checkbox_field, value: 'Test')
      option2 = create(:inventory_field_option, field: checkbox_field, value: 'Test2')
      valid_params['data'][checkbox_field.id] = [option1.id, option2.id]

      last_item = category.items.last

      post "/inventory/categories/#{category.id}/items", valid_params, auth(user)
      expect(response.status).to eq(201)
      body = parsed_body

      expect(body).to include('message')

      checkbox_data = category.items.last.data.find_by(inventory_field_id: checkbox_field.id)
      expect(category.items.last).to_not be_nil
      expect(category.items.last.data).to_not be_empty
      expect(checkbox_data.content).to eq([option1.id, option2.id])
      expect(checkbox_data.selected_options).to eq([option1, option2])
      expect(category.items.last.user).to_not be_nil
    end
  end

  context 'GET /inventory/categories/:cat_id/items/:id' do
    let(:category) { create(:inventory_category_with_sections) }
    let(:item) { create(:inventory_item) }
    let(:field) { item.data.first.field }

    it 'returns the item info' do
      get "/inventory/categories/#{item.category.id}/items/#{item.id}",
          {}, auth(user)

      expect(response.status).to eq(200)
      body = parsed_body

      expect(body).to include('item')
      expect(body['item']['id']).to eq(item.id)
      expect(body['item']['position']).to_not be_nil
    end

    it "returns the item with it's data" do
      get "/inventory/categories/#{item.category.id}/items/#{item.id}",
      {}, auth(user)

      expect(response.status).to eq(200)
      body = parsed_body

      item_data = body['item']
      expect(item_data).to include('data')
      expect(item_data['data']).to_not be_empty
      expect(item_data['data'].first['content']).to eq(item.data.first.converted_content)
      expect(item_data['position']).to_not be_nil
      expect(item_data['position']['latitude']).to_not be_nil
      expect(item_data['position']['longitude']).to_not be_nil
    end

    it "returns the item with it's data even having the field disabled" do
      field.update(disabled: true)

      get "/inventory/categories/#{item.category.id}/items/#{item.id}",
      {}, auth(user)

      expect(response.status).to eq(200)
      body = parsed_body

      item_data = body['item']
      expect(item_data).to include('data')
      expect(item_data['data']).to_not be_empty
      expect(item_data['data'].first['content']).to eq(item.data.first.converted_content)
      expect(item_data['data'].first['field']['id']).to eq(field.id)
    end
  end

  context 'DELETE /inventory/categories/:cat_id/items/:id' do
    let(:category) { create(:inventory_category_with_sections) }
    let(:item) { create(:inventory_item) }

    it 'destroys the item' do
      delete "/inventory/categories/#{item.category.id}/items/#{item.id}",
             {}, auth(user)

      expect(response.status).to eq(200)
      expect(Inventory::Item.find_by(id: item.id)).to be_nil
    end
  end

  context 'PUT /inventory/categories/:id/items/:id' do
    let(:category) { create(:inventory_category_with_sections) }
    let(:item) { create(:inventory_item, category: category) }
    let(:item_data) { item.data.joins(:field).where(inventory_fields: { kind: 'text' }).last }
    let!(:formula) { create(:inventory_formula, category: category) }
    let(:valid_params) do
      Oj.load <<-JSON
        {
          "data": {}
        }
      JSON
    end

    it 'updates the item object' do
      valid_params['data'][item_data.field.id] = 'Test'

      put "/inventory/categories/#{category.id}/items/#{item.id}", valid_params, auth(user)
      expect(response.status).to eq(200)
      expect(parsed_body).to include('message')
      item_data.reload
      expect(item_data.content).to eq('Test')
    end

    it 'executes formulas' do
      valid_params['data'][item_data.field.id] = 'Test'

      put "/inventory/categories/#{category.id}/items/#{item.id}", valid_params, auth(user)
      expect(response.status).to eq(200)
      expect(item.reload.status).to eq(formula.status)
    end

    context 'updating status' do
      let(:status) { create(:inventory_status, category: category) }
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "inventory_status_id": #{status.id},
            "data": {}
          }
        JSON
      end

      it 'updates the item status' do
        put "/inventory/categories/#{category.id}/items/#{item.id}", valid_params, auth(user)
        expect(response.status).to eq(200)
        expect(item.reload.status).to eq(status)
      end

      it 'doesn\'t executes formulas' do
        valid_params['data'][item_data.field.id] = 'Test'

        put "/inventory/categories/#{category.id}/items/#{item.id}", valid_params, auth(user)
        expect(response.status).to eq(200)
        expect(item.reload.status).to_not eq(formula.status)
      end
    end

    context 'removing a image from item data' do
      it 'removes the image' do
        images_field_id = category.sections.last.fields.create(
          title: 'Imagens',
          kind: 'images',
          position: 0
        ).id

        data = item.data.where(inventory_field_id: images_field_id).first
        image = data.images.create(image: fixture_file_upload("#{Application.config.root}/spec/fixtures/images/valid_report_item_photo.jpg"))

        expect(data.reload.images).to_not be_empty

        valid_params['data'][images_field_id] = [
          {
            id: image.id,
            destroy: true
          }
        ]

        put "/inventory/categories/#{category.id}/items/#{item.id}", valid_params, auth(user)
        expect(data.reload.images).to be_empty
      end
    end

    context 'removing an attachment from item data' do
      it 'removes the attachment' do
        attachments_field_id = category.sections.last.fields.create(
          title: 'Anexos',
          kind: 'attachments',
          position: 0
        ).id

        data = item.data.where(inventory_field_id: attachments_field_id).first
        attachment = data.attachments.create(attachment: fixture_file_upload("#{Application.config.root}/spec/fixtures/images/valid_report_item_photo.jpg"))

        expect(data.reload.attachments).to_not be_empty

        valid_params['data'][attachments_field_id] = [
          {
            id: attachment.id,
            destroy: true
          }
        ]

        put "/inventory/categories/#{category.id}/items/#{item.id}", valid_params, auth(user)
        expect(data.reload.attachments).to be_empty
      end
    end

    context 'adding a image to item data' do
      it 'adds a new images to item data' do
        images_field_id = category.sections.last.fields.create(
          title: 'Imagens',
          kind: 'images',
          position: 0
        ).id

        data = item.data.where(inventory_field_id: images_field_id).first
        image = data.images.create(image: fixture_file_upload("#{Application.config.root}/spec/fixtures/images/valid_report_item_photo.jpg"))

        expect(data.reload.images).to_not be_empty

        valid_params['data'][images_field_id] = [
          {
            content: Base64.encode64(fixture_file_upload("#{Application.config.root}/spec/fixtures/images/valid_report_item_photo.jpg").read)
          }
        ]

        put "/inventory/categories/#{category.id}/items/#{item.id}", valid_params, auth(user)
        expect(data.reload.images.count).to eq(2)
      end
    end

    context 'item locked' do
      let(:locker) { create(:user) }

      before do
        item.update(locked: true, locked_at: Time.now, locker: locker)
      end

      context 'user is not the locker' do
        it "can't edit" do
          put "/inventory/categories/#{category.id}/items/#{item.id}", valid_params, auth(user)
          expect(response.status).to eq(200)
          body = parsed_body

          expect(body['locker']['id']).to eq(locker.id)
          expect(body['message']).to_not be_empty
          expect(body['locked_at']).to be < 1.minute.from_now
        end
      end

      context 'user is locked' do
        it 'can edit' do
          put "/inventory/categories/#{category.id}/items/#{item.id}", valid_params, auth(locker)
          expect(response.status).to eq(200)
          body = parsed_body

          expect(body['locker']).to be_nil
          expect(body['message']).to_not be_empty
        end
      end
    end

    context 'related inventories' do
      let(:item_one) { create(:inventory_item, category: category)  }
      let(:item_two) { create(:inventory_item, category: category)  }

      let(:valid_params) do
        {
          inventory_ids: [item_one.id, item_two.id]
        }
      end

      it 'adds a new item to relationship' do
        put "/inventory/categories/#{category.id}/items/#{item.id}", valid_params, auth(user)

        expect(response.status).to eq(200)
        body = parsed_body['item']

        returned_ids = body['inventories'].map { |i| i['id'] }

        expect(returned_ids).to match_array([item_one.id, item_two.id])

        expect(item_one.inventories.pluck(:id)).to include(item.id)
        expect(item_two.inventories.pluck(:id)).to include(item.id)
      end

      it 'removes an existing item from relationship' do
        valid_params[:inventory_ids].delete(item_two.id)

        put "/inventory/categories/#{category.id}/items/#{item.id}", valid_params, auth(user)

        expect(response.status).to eq(200)
        body = parsed_body['item']

        returned_ids = body['inventories'].map { |i| i['id'] }

        expect(returned_ids).to include(item_one.id)
        expect(returned_ids).to_not include(item_two.id)

        expect(item_one.inventories.pluck(:id)).to include(item.id)
        expect(item_two.inventories.pluck(:id)).to be_empty
      end
    end
  end

  context 'GET /inventory/items/:id' do
    let(:item) { create(:inventory_item) }

    it 'returns the info about the item' do
      get "/inventory/items/#{item.id}", nil, auth(user)
      expect(response.status).to be_a_success_request
      body = parsed_body

      expect(body['item']['id']).to eq(item.id)
    end
  end

  context 'GET /inventory/categories/:id/items' do
    let!(:category) { create(:inventory_category_with_sections) }
    let!(:items) { create_list(:inventory_item, 5, category: category) }
    let(:category_params) do
      Oj.load <<-JSON
        {
          "inventory_category_id": #{category.id}
        }
      JSON
    end

    context 'param as array' do
      let(:other_category) { create(:inventory_category_with_sections) }
      let!(:other_items) { create_list(:inventory_item, 2, category: other_category) }

      it 'accepts array as argument of inventory categories' do
        category_params['inventory_category_id'] = [category.id, other_category.id]
        get '/inventory/items', category_params, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body['items'].size).to eq(7)
      end
    end

    context 'pagination' do
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "per_page": 2
          }
        JSON
      end

      it "returns the correct number of records on 'per_page'" do
        get '/inventory/items', valid_params, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body['items'].size).to eq(2)
      end

      it 'returns all inventory items paginated' do
        valid_params['page'] = 2
        get '/inventory/items', valid_params, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body['items'].size).to eq(2)
        expect(
          body['items'].map do |item|
            item['id']
          end
        ).to_not eq(items[0..1].map(&:id))
      end

      it 'return all inventory items ordenated and paginated' do
        ordered_items = Inventory::Item.where(id: items.map(&:id)).order(id: :asc)

        get '/inventory/items?page=2&per_page=3&sort=id&order=desc',
            nil, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body).to include('items')
        expect(body['items'].size).to eq(2)
        expect(body['items'][0]['id']).to eq(ordered_items[1].id)
      end
    end

    context 'without filters' do
      it 'returns all items from a category' do
        get '/inventory/items', category_params, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body).to include('items')
        expect(body['items'].size).to eq(5)
      end
    end

    # Commenting for now, because this will change
    #context "searching by fields" do
    #  let!(:category_for_search) { create(:inventory_category_with_sections) }
    #  let(:valid_params) do
    #    @item, @item2 = items.sample(2)
    #    item_data = @item.data.first
    #    item_data2 = @item2.data.first

    #    Oj.load <<-JSON
    #      {
    #        "filters": [{
    #          "field_id": #{item_data.inventory_field_id},
    #          "content": "#{item_data.content}"
    #        }, {
    #          "field_id": #{item_data2.inventory_field_id},
    #          "content": "#{item_data2.content}"
    #        }]
    #      }
    #    JSON
    #  end

    #  it "returns all items satisfying the search" do
    #    get "/inventory/items", valid_params.merge({
    #      category_id: category_for_search.id
    #    }), auth(user)
    #    expect(response.status).to eq(200)
    #    body = parsed_body

    #    expect(body).to include("items")
    #    expect(body["items"].map { |item| item["id"] }).to match_array([@item.id, @item2.id])
    #  end
    #end

    context 'empty results' do
      let(:category_without_items) { create(:inventory_category) }

      it 'retuns empty array' do
        get '/inventory/items',
            { inventory_category_id: category_without_items.id }, auth(user)

        expect(response.status).to eq(200)
        body = parsed_body

        expect(body).to include('items')
        expect(body['items'].size).to eq(0)
      end
    end

    context 'basic display type' do
      it "doesn't return the `data`" do
        get '/inventory/items',
          {
            inventory_category_id: category.id,
            display_type: 'basic'
          }, auth(user)

        expect(response.status).to eq(200)
        body = parsed_body

        expect(body['items'].first['data']).to be_nil
      end
    end

    context 'guest group' do
      let(:other_category) { create(:inventory_category_with_sections) }
      let!(:other_items) { create_list(:inventory_item, 2, category: other_category) }

      before do
        Group.guest.each do |group|
          group.permission.inventories_items_read_only = [other_category.id]
          group.save!
        end
      end

      it 'only can see the category it has the permission' do
        get '/inventory/items', nil, auth(nil, user.namespace_id)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body['items'].size).to eq(2)
        expect(body['items'].map do |i|
          i['id']
        end).to match_array(other_items.map(&:id))
      end
    end

    context 'search by position' do
      let(:empty_category) { create(:inventory_category) }
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "position": {
              "latitude": "-23.5989650",
              "longitude": "-46.6836310",
              "distance": 1000
            }
          }
        JSON
      end

      it 'returns closer item positions when passed position arg' do
        # Creating items
        points_nearby = [
          [-23.5989650, -46.6836310],
          [-23.5989340, -46.6835700],
          [-23.5981840, -46.6842480],
          [-23.5986170, -46.6828580]
        ]

        points_distant = [
          [FFaker::Geolocation.lat, FFaker::Geolocation.lng],
          [FFaker::Geolocation.lat, FFaker::Geolocation.lng],
          [FFaker::Geolocation.lat, FFaker::Geolocation.lng],
          [FFaker::Geolocation.lat, FFaker::Geolocation.lng]
        ]

        latitude_field, longitude_field = nil

        empty_category.fields.location.each do |field|
          if field.title == 'latitude'
            latitude_field = field.id
          elsif field.title == 'longitude'
            longitude_field = field.id
          end
        end

        nearby_items = points_nearby.map do |latlng|
          Inventory::CreateItemFromCategoryForm.new(
            category: empty_category,
            user: user,
            namespace_id: user.namespace_id,
            data: {
                    latitude_field => latlng[0],
                    longitude_field => latlng[1]
                  }
          ).create!
        end

        distant_items = points_distant.map do |latlng|
          Inventory::CreateItemFromCategoryForm.new(
            category: empty_category,
            user: user,
            namespace_id: user.namespace_id,
            data: {
                    latitude_field => latlng[0],
                    longitude_field => latlng[1]
                  }
          ).create!
        end

        expect(empty_category.items.count).to eq(8)
        expect(empty_category.items.map(&:position)).to_not include(nil)

        get '/inventory/items',
            valid_params.merge(inventory_category_id: empty_category.id), auth(user)

        expect(response.status).to eq(200)
        body = parsed_body

        expect(body['items'].map { |i| i['id'] }).to match_array(nearby_items.map { |i| i['id'] })
      end
    end
  end

  context 'PATCH /inventory/categories/:category_id/item/:id/update_access' do
    let(:category) { create(:inventory_category_with_sections) }
    let(:item) { create(:inventory_item, category: category) }

    it 'locks the inventory item' do
      patch "/inventory/categories/#{category.id}/items/#{item.id}/update_access", nil, auth(user)
      expect(response.status).to eq(200)

      item.reload
      expect(item).to be_locked
      expect(item.locker).to eq(user)
    end
  end
end
