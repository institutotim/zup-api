require 'spec_helper'

describe Inventory::Categories::API do
  let(:namespace) { create(:namespace) }
  let(:user) { create(:user, namespace: namespace) }

  context 'POST /inventory/categories' do
    let!(:valid_params) do
      p = Oj.load <<-JSON
        {
          "title": "Awesome category",
          "description": "Check this category!",
          "plot_format": "pin",
          "color": "#e2e2e2",
          "require_item_status": true,
          "statuses": [{
            "title": "Initial Status",
            "color": "#ff0000"
          }]
        }
      JSON

      p.merge(
        'icon' => Base64.encode64(fixture_file_upload("#{Application.config.root}/spec/fixtures/images/valid_report_category_icon.png").read)
      )
    end

    it 'creates the category' do
      post '/inventory/categories', valid_params, auth(user)
      expect(response.status).to eq(201)
      body = parsed_body

      expect(body).to include('message')
      expect(body).to include('category')
      expect(body['category']).to_not be_empty
      expect(body['category']['namespace']['id']).to eq(user.namespace_id)

      last_category = Inventory::Category.last

      expect(last_category.title).to eq('Awesome category')
      expect(last_category.description).to eq('Check this category!')
      expect(last_category.color).to eq('#e2e2e2')
      expect(last_category.require_item_status).to eq(true)
      expect(last_category.statuses).to_not be_empty
    end

    context 'permissions' do
      let(:group) { create(:group) }
      it 'updates the permissions groups_can_view' do
        valid_params['permissions'] = {
          'groups_can_view' => [group.id]
        }
        expect(group.permission.inventories_items_read_only).to be_empty

        post '/inventory/categories', valid_params, auth(user)
        expect(response.status).to eq(201)
        body = parsed_body
        group.reload

        last_category = Inventory::Category.last
        expect(group.permission.inventories_items_read_only).to eq([last_category.id])
      end
    end
  end

  context 'GET /inventory/categories/:id' do
    let(:category) { create(:inventory_category) }
    let(:valid_params) do
      Oj.load <<-JSON
        {
          "display_type": "full"
        }
      JSON
    end

    it 'returns the category' do
      get "/inventory/categories/#{category.id}", valid_params, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body['category']

      expect(body['id']).to eq(category.id)
      expect(body).to include('sections')
      expect(body['pin']).to_not be_empty
      expect(body['icon']).to_not be_empty
      expect(body['marker']).to_not be_empty
      expect(body['icon'].keys).to match_array(['default', 'retina'])
      expect(body['pin'].keys).to match_array(['default', 'retina'])
      expect(body['marker'].keys).to match_array(['default', 'retina'])
      expect(body['original_icon']).to_not be_empty
      expect(body['sections']).to_not be_empty
    end

    it "returns error if category id doesn't exists" do
      get '/inventory/categories/123123123', nil, auth(user)
      expect(response.status).to eq(404)
      expect(parsed_body).to include('error')
    end

    context 'user only has permissions to see some fields of the category' do
      let(:group) do
        create(:group)
      end
      let(:user) do
        create(:user, groups: [group])
      end
      let(:field) do
        category.fields.first
      end

      before do
        group.permission.update(
          inventories_items_read_only: [category.id],
          inventory_sections_can_edit: [field.section.id],
          inventory_fields_can_edit: [field.id]
        )
      end

      it 'returns only some fields from the category' do
        get "/inventory/categories/#{category.id}", valid_params, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body['category']

        expect(body['sections'].size).to eq(1)
        section = body['sections'].first
        expect(section['id']).to eq(field.section.id)

        expect(section['fields'].size).to eq(1)
        returned_field = section['fields'].first
        expect(returned_field['id']).to eq(field.id)
      end
    end
  end

  context 'PUT /inventory/categories/:id' do
    let(:category) { create(:inventory_category) }
    let(:valid_params) do
      Oj.load <<-JSON
        {
          "title": "A COOLER NAME!",
          "description": "A COOLER DESCRIPTION!",
          "require_item_status": true
        }
      JSON
    end

    it 'updates the category' do
      put "/inventory/categories/#{category.id}", valid_params, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body

      expect(body).to include('message')
      category.reload
      expect(category.title).to eq('A COOLER NAME!')
      expect(category.description).to eq('A COOLER DESCRIPTION!')
      expect(category.require_item_status).to eq(true)
    end

    it "return error messages if record doesn't exists" do
      put '/inventory/categories/12312312', valid_params, auth(user)
      expect(response.status).to eq(404)
      expect(parsed_body).to include('error')
    end

    context 'permissions' do
      let(:group) { create(:group) }

      it 'updates the permissions groups_can_view' do
        valid_params['permissions'] = {
          'groups_can_view' => [group.id]
        }
        expect(group.permission.inventories_items_read_only).to be_empty

        put "/inventory/categories/#{category.id}", valid_params, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body
        group.reload

        last_category = Inventory::Category.last
        expect(group.permission.inventories_items_read_only).to eq([last_category.id])
      end
    end
  end

  context 'GET /inventory/categories' do
    let!(:category) { create(:inventory_category, title: 'Bueiros') }
    let!(:categories) { create_list(:inventory_category, 5) }
    let(:valid_params) do
      Oj.load <<-JSON
        {
          "title": "bue"
        }
      JSON
    end

    it 'returns all categories when no params are given' do
      get '/inventory/categories', nil, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body

      expect(body).to include('categories')
      expect(body['categories'].size).to eq(6)
    end

    it 'return category with specified title (partial)' do
      get '/inventory/categories', valid_params, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body

      expect(body).to include('categories')
      expect(body['categories'].size).to eq(1)
      expect(body['categories'].first['title']).to eq(category.title)
    end

    context 'pagination' do
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "per_page": 3
          }
        JSON
      end

      it "returns the correct number of records on 'per_page'" do
        get '/inventory/categories', valid_params, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body['categories'].size).to eq(3)
      end

      it 'returns all categories paginated' do
        valid_params['page'] = 2
        get '/inventory/categories', valid_params, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body['categories'].size).to eq(3)
        expect(
          body['categories'].map do |category|
            category['id']
          end
        ).to_not eq(categories[0..2].map(&:id))
      end
    end

    context "when the user doesn't have permission to see inventory" do
      let(:group) { create(:group) }
      let(:allowed_category) { categories.sample }

      before do
        group.permission.inventories_items_read_only = [allowed_category.id]
        group.save!
        user.groups = [group]
        user.save!
      end

      it 'returns only the category' do
        get '/inventory/categories', nil, auth(user)
        expect(response.status).to eq(200)
        body = parsed_body

        expect(body).to include('categories')
        expect(body['categories'].size).to eq(1)
        expect(body['categories'].first['id']).to eq(allowed_category.id)
      end
    end
  end

  context 'DELETE /inventory/categories/:id' do
    let(:category) { create(:inventory_category) }

    it 'destroys the category' do
      delete "/inventory/categories/#{category.id}", nil, auth(user)
      expect(response.status).to eq(200)
      expect(parsed_body).to include('message')

      category.reload

      expect(category.deleted_at).to_not be_nil
      expect(Inventory::Category.active.find_by(id: category.id)).to be_nil
    end
  end

  context 'PUT /inventory/categories/:id/restore' do
    let(:category) { create(:inventory_category, :deleted) }

    it 'restores the category' do
      put "/inventory/categories/#{category.id}/restore", nil, auth(user)
      expect(response.status).to eq(200)
      expect(parsed_body).to include('message')

      category.reload

      expect(category.deleted_at).to be_nil
      expect(Inventory::Category.deleted.find_by(id: category.id)).to be_nil
    end
  end

  context 'GET /inventory/categories/deleted' do
   let!(:deleted_category) { create(:inventory_category, :deleted) }
   let!(:category)         { create(:inventory_category) }

   it 'returns all deleted inventory categories' do
     get '/inventory/categories/deleted', nil, auth(user)

     expect(response.status).to eq(200)

     returned_ids = parsed_body['categories'].map { |c| c['id'] }

     expect(returned_ids).to include(deleted_category.id)
     expect(returned_ids).to_not include(category.id)
   end
  end

  context 'PUT /inventory/categories/:id/form' do
    let(:category) { create(:inventory_category) }
    let(:valid_params) do
      Oj.load <<-JSON
        {
          "sections": [{
            "title": "Dados técnicos",
            "permissions": {},
            "position": 1,
            "fields": [{
              "title": "latitude",
              "kind": "text",
              "size": "M",
              "permissions": {},
              "label": "Latitude",
              "position": 0,
              "maximum": 10,
              "minimum": 1,
              "required": true
            }]
          }]
        }
      JSON
    end

    it 'creates the sections and fields correctly' do
      put "/inventory/categories/#{category.id}/form", valid_params, auth(user)
      expect(response.status).to eq(200)
      expect(parsed_body).to include('message')
      created_section = category.reload.sections.last
      created_field = created_section.fields.first

      expect(created_section.title).to eq('Dados técnicos')
      expect(created_section.id).to_not be_nil
      expect(created_section.position).to eq(1)
      expect(created_field.title).to eq('latitude')
      expect(created_field.id).to_not be_nil
      expect(created_field.maximum).to eq(10)
      expect(created_field.minimum).to eq(1)
      expect(created_field.required).to be_truthy
    end

    it 'updates the section and field if it already exists' do
      section = category.sections.create(title: generate(:name))
      field = section.fields.create(title: 'anotherfield', position: 10, kind: 'url')
      valid_params['sections'].first['fields'].first['id'] = field.id
      valid_params['sections'].first['id'] = section.id

      put "/inventory/categories/#{category.id}/form", valid_params, auth(user)

      expect(response.status).to eq(200)
      expect(parsed_body).to include('message')
      field.reload
      expect(field.title).to eq('latitude')
      expect(field.position).to eq(0)
      expect(field.kind).to eq('text')
      expect(field.options).to_not be_blank
    end

    context 'category locked' do
      let(:locker) { create(:user) }

      before do
        category.update(locked: true, locked_at: Time.now, locker: locker)
      end

      context 'user is not the locker' do
        it "can't edit" do
          put "/inventory/categories/#{category.id}/form", valid_params, auth(user)
          expect(response.status).to eq(200)
          body = parsed_body

          expect(body['locker']['id']).to eq(locker.id)
          expect(body['message']).to_not be_empty
          expect(body['locked_at']).to be < 1.minute.from_now
        end
      end

      context 'user is locked' do
        it 'can edit' do
          put "/inventory/categories/#{category.id}/form", valid_params, auth(locker)
          expect(response.status).to eq(200)
          body = parsed_body

          expect(body['locker']).to be_nil
          expect(body['message']).to_not be_empty
        end
      end
    end
  end

  context 'GET /inventory/categories/:id/form' do
    let!(:category) { create(:inventory_category_with_sections) }

    it 'returns the form for the category, including sections and fields' do
      get "/inventory/categories/#{category.id}/form", nil, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body
      expect(body).to include('sections')
      expect(body['sections'].map { |d| d['title'] }).to eq(category.sections.map(&:title))

      # Section needs to has its permissions
      section = body['sections'].first
      expect(section['permissions']).to_not be_nil
    end
  end

  context 'PATCH /inventory/categories/:id/updates_access' do
    let(:category) { create(:inventory_category_with_sections) }

    it 'locks the inventory category' do
      patch "/inventory/categories/#{category.id}/update_access", nil, auth(user)
      expect(response.status).to eq(200)

      category.reload
      expect(category).to be_locked
      expect(category.locker).to eq(user)
    end
  end
end
