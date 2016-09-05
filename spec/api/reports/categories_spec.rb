require 'app_helper'

describe Reports::Categories::API do
  let(:user) { create(:user) }
  let!(:inventory_categories) { create_list(:inventory_category, 3) }

  let(:valid_params) do
    {
        title: 'A very cool report category',
        icon: Base64.encode64(fixture_file_upload("#{Application.config.root}/spec/fixtures/images/valid_report_category_icon.png").read),
        marker: Base64.encode64(fixture_file_upload("#{Application.config.root}/spec/fixtures/images/valid_report_category_marker.png").read),
        resolution_time: 2 * 60 * 60 * 24,
        user_response_time: 1 * 60 * 60 * 24,
        color: '#f3f3f3',
        priority: 'high',
        inventory_categories: inventory_categories.map(&:id),
        confidential: true,
        statuses: {
          0 =>  { title: 'Open', color: '#ff0000', initial: true, final: false, active: true, private: false },
          1 =>  { title: 'Closed', color: '#f4f4f4', final: true, initial: false, active: false, private: false }
        }
    }
  end

  context 'POST /reports/categories' do
    it 'creates the report category provided valid params are given' do
      post '/reports/categories', valid_params, auth(user)

      expect(response.status).to eq(201)
      body = parsed_body

      statuses = body['category']['statuses'].map { |st| st['title'] }

      expect(statuses).to match_array(['Open', 'Closed'])

      valid_params.except(:inventory_categories, :token, :statuses, :marker, :icon).each do |param_key, param_value|
        expect(body['category'][param_key.to_s]).to eq(param_value)
      end

      expect(body['category']['inventory_categories']).to_not be_empty
      expect(body['category']['marker']).to_not be_empty
      expect(body['category']['icon']).to_not be_empty
    end

    it 'validates the format of the status' do
      valid_params[:statuses] = {
        0 => { test: '11' },
        1 => { test: '11' }
      }

      post '/reports/categories', valid_params, auth(user)
      expect(response.status).to eq(400)
      body = parsed_body

      expect(body['error'].keys).to match_array(['title', 'color', 'initial', 'final', 'active', 'private'])
    end

    it 'creates a subcategory' do
      category = create(:reports_category)

      valid_params[:parent_id] = category.id
      post '/reports/categories', valid_params, auth(user)
      body = parsed_body

      expect(body['category']['parent_id']).to eq(category.id)
    end

    it 'assign solver groups for this report category' do
      groups = create_list(:group, 3)
      valid_params[:solver_groups_ids] = groups.map(&:id)

      post '/reports/categories', valid_params, auth(user)
      category = Reports::Category.last
      setting = category.setting

      expect(setting.solver_groups_ids).to match_array(groups.map(&:id))
      expect(setting.solver_groups).to match_array(groups)
    end

    it 'assigns default solver group for this report category' do
      group = create(:group)
      valid_params[:default_solver_group_id] = group.id

      post '/reports/categories', valid_params, auth(user)
      category = Reports::Category.last
      setting = category.setting

      expect(setting.default_solver_group).to eq(group)
    end

    it 'accepts attributes for custom fields' do
      custom_fields_attributes = [
        {
          'title' => 'Extra field 1',
          'multiline' => false
        },
        {
          'title' => 'Extra field 2',
          'multiline' => true
        }
      ]

      valid_params[:custom_fields] = custom_fields_attributes

      post '/reports/categories', valid_params, auth(user)

      expect(response.status).to eq(201)
      category = Reports::Category.last

      expect(category.custom_fields.size).to eq(2)
      category.custom_fields.each_with_index do |custom_field, i|
        expect(custom_field.title).to eq(custom_fields_attributes[i]['title'])
        expect(custom_field.multiline).to eq(custom_fields_attributes[i]['multiline'])
      end

      expect(parsed_body['category']['custom_fields']).to match_array([
        {
          'id' => an_instance_of(Fixnum),
          'title' => 'Extra field 1',
          'multiline' => false
        },
        {
          'id' => an_instance_of(Fixnum),
          'title' => 'Extra field 2',
          'multiline' => true
        }
      ])
    end
  end

  context 'GET /reports/categories/:id' do
    let(:category) { create(:reports_category_with_statuses) }

    it 'should display an category' do
      get "/reports/categories/#{category.id}", nil, auth(nil, user.namespace_id)
      expect(response.status).to eq(200)
      body = parsed_body['category']
      expect(body['id']).to eq(category.id)
    end

    context 'category with subcategory' do
      let!(:subcategory) { create(:reports_category_with_statuses, parent_category: category) }

      it 'should return the subcategories' do
        get "/reports/categories/#{category.id}", { display_type: 'full' }, auth(nil, user.namespace_id)
        expect(response.status).to eq(200)
        body = parsed_body
        expect(body['category']['subcategories']).to_not be_empty
        expect(body['category']['subcategories'].first['id']).to eq(subcategory.id)
      end
    end
  end

  context 'GET /reports/categories' do
    let!(:categories) { create_list(:reports_category_with_statuses, 3) }

    it 'displays a list of categories including control properties' do
      get '/reports/categories?display_type=full&return_fields=id,icon,marker,statuses,resolution_time,user_response_time,allows_arbitrary_position,created_at,updated_at,active', nil, auth(user)
      expect(response.status).to eq(200)

      body = parsed_body['categories']
      expect(body.count).to eq(3)

      body.each do |category|
        expect(category).to include('id')
        expect(category).to include('icon')
        expect(category['icon']).to_not be_empty
        expect(category).to include('marker')
        expect(category['marker']).to_not be_empty
        expect(category).to include('resolution_time')
        expect(category).to include('user_response_time')
        expect(category).to include('statuses')
        expect(category['statuses'].count).to eq(4)
        expect(category).to include('allows_arbitrary_position')
        expect(category).to include('created_at')
        expect(category).to include('updated_at')
        expect(category).to include('active')
      end
    end

    it 'displays a list of categories, excluding control properties' do
      get '/reports/categories', nil, auth(user)
      body = parsed_body['categories']

      expect(body.count).to eq(3)

      body.each do |category|
        expect(category).to include('id')
        expect(category).to include('icon')
        expect(category['icon']).to_not be_empty
        expect(category).to include('marker')
        expect(category['marker']).to_not be_empty
        expect(category).to include('resolution_time')
        expect(category).to include('user_response_time')
        expect(category).to include('statuses')
        expect(category['statuses'].count).to eq(4)
        expect(category).to include('allows_arbitrary_position')
        expect(category).to_not include('created_at')
        expect(category).to_not include('updated_at')
        expect(category).to_not include('active')
      end
    end

    context 'subcategories_flat param' do
      let!(:subcategories) { create(:reports_category, parent_id: categories.first.id) }

      before do
        user
        Group.guest.first.permission.update(reports_full_access: true)
      end

      context 'if param is set to true' do
        it 'returns subcategories along with categories' do
          get '/reports/categories?subcategories_flat=true', nil, auth(nil, user.namespace_id)
          expect(response.status).to eq(200)

          expect(parsed_body['categories'].map do |c|
                   c['id']
                 end).to match(Reports::Category.pluck(:id))
        end
      end
    end

    context 'filters and permissions' do
      let!(:category_can_view) { create(:reports_category) }
      let!(:category_can_edit) { create(:reports_category) }

      before do
        user
        Group.all.each do |group|
          group.permission.update(manage_reports_categories: false,
                                  reports_full_access: false,
                                  reports_items_read_private: [category_can_view.id],
                                  reports_items_create: [category_can_edit.id],
                                  reports_items_read_public: [])
        end
      end

      it 'returns only categories that user can view' do
        get '/reports/categories', nil, auth(user)

        expect(response.status).to eq(200)

        body = parsed_body['categories']

        expect(body.count).to eq(2)
        expect(body.map { |b| b['id'] }).to include(category_can_view.id, category_can_edit.id)
      end

      it 'returns only category that user can create' do
        get '/reports/categories', { creatable: true }, auth(user)

        expect(response.status).to eq(200)

        body = parsed_body['categories']
        expect(body.count).to eq(1)

        category = body.first

        expect(category['id']).to eq(category_can_edit.id)
      end
    end
  end

  context 'PUT /reports/categories/:id' do
    it 'should update a category' do
      category = create(:reports_category_with_statuses)

      put '/reports/categories/' + category.id.to_s, valid_params, auth(user)
      body = parsed_body

      expect(response.status).to eq(200)
      expect(body['category']).to_not be_blank

      category.reload

      expect(category.statuses.map { |s| s.title }).to match_array(['Open', 'Closed'])

      expect(category.inventory_categories.pluck(:id)).to \
        match_array(valid_params[:inventory_categories])

      expect(category.title).to eq(valid_params[:title])
      expect(category.color).to eq(valid_params[:color])
      expect(category[:icon]).to_not be_empty
      expect(category[:marker]).to_not be_empty
    end

    context 'updating the confidentiality of reports' do
      let(:category) { create(:reports_category_with_statuses) }

      it 'updates the confidential flag' do
        valid_params[:confidential] = true

        put '/reports/categories/' + category.id.to_s, valid_params, auth(user)

        expect(response.status).to eq(200)

        category.reload
        setting = category.setting

        expect(setting).to be_confidential
        expect(category).to_not be_confidential
      end
    end

    context 'updating assigned groups solver' do
      let(:category) { create(:reports_category_with_statuses) }

      it 'updates the assigned groups' do
        groups = create_list(:group, 3)
        valid_params[:solver_groups_ids] = groups.map(&:id)

        put "/reports/categories/#{category.id}", valid_params, auth(user)
        expect(response.status).to eq(200)

        setting = category.setting

        expect(setting.solver_groups).to match_array(groups)
      end

      it 'assigns default solver group for this report category' do
        group = create(:group)
        valid_params[:default_solver_group_id] = group.id

        put "/reports/categories/#{category.id}", valid_params, auth(user)

        setting = category.setting

        expect(setting.default_solver_group).to eq(group)
      end
    end

    context 'changing the statuses' do
      let(:category) { create(:reports_category_with_statuses) }
      let(:another_category) { create(:reports_category_with_statuses) }

      it 'updates the statuses' do
        valid_params = {
          statuses: {
            0 =>  { title: 'This is a test', color: '#ff0000', initial: true, final: false, active: true, private: false },
            1 =>  { title: 'This is another test', color: '#f4f4f4', final: true, initial: false, active: false, private: false }
          }
        }

        put "/reports/categories/#{category.id}", valid_params, auth(user)

        category.reload

        expect(category.statuses.map(&:title)).to match_array(['This is a test', 'This is another test'])
        expect(another_category.statuses).to_not be_empty
      end
    end

    it 'accepts attributes for custom fields' do
      category = create(:reports_category_with_statuses)

      custom_fields_attributes = [
        {
          'title' => 'Extra field 1',
          'multiline' => false
        },
        {
          'title' => 'Extra field 2',
          'multiline' => true
        }
      ]
      valid_params[:custom_fields] = custom_fields_attributes

      put "/reports/categories/#{category.id}", valid_params, auth(user)

      expect(response.status).to eq(200)
      category = Reports::Category.last

      expect(category.custom_fields.size).to eq(2)
      category.custom_fields.each_with_index do |custom_field, i|
        expect(custom_field.title).to eq(custom_fields_attributes[i]['title'])
        expect(custom_field.multiline).to eq(custom_fields_attributes[i]['multiline'])
      end

      expect(parsed_body['category']['custom_fields']).to match_array([
        {
          'id' => an_instance_of(Fixnum),
          'title' => 'Extra field 1',
          'multiline' => false
        },
        {
          'id' => an_instance_of(Fixnum),
          'title' => 'Extra field 2',
          'multiline' => true
        }
      ])
    end
  end

  context 'DELETE /reports/categories/:id' do
    let(:category) { create(:inventory_category) }

    it 'destroys a reports category' do
      category = create(:reports_category_with_statuses)
      delete "/reports/categories/#{category.id}", nil, auth(user)
      expect(response.status).to eq(204)
      expect(Reports::Category.find_by(id: category.id)).to be_nil
    end
  end
end
