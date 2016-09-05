require 'app_helper'

describe 'Namespaces Inventory Categories' do
  let(:namespace_one) { create(:namespace) }
  let(:namespace_two) { create(:namespace) }

  let(:permissions)   do
    create(
      :admin_permissions,
      manage_namespaces: false,
      namespaces_access: [namespace_one.id]
    )
  end

  let(:group) { create(:group, permission: permissions) }
  let(:user)  { create(:user, groups: [group]) }

  context 'collections' do
    let!(:category_one)   { create(:inventory_category, namespace: namespace_one) }
    let!(:category_two)   { create(:inventory_category, namespace: namespace_two) }
    let!(:category_three) { create(:inventory_category) }

    describe 'GET /inventory/categories' do
      it 'filter categories by namespaces of user' do
        get '/inventory/categories', nil, auth(user, namespace_one.id)

        expect(response.status).to be_a_success_request

        json = parsed_body['categories']

        expect(json.size).to eq(2)

        returned_ids = json.map { |g| g['id'] }

        expect(returned_ids).to include(category_one.id)
        expect(returned_ids).to_not include(category_two.id)
        expect(returned_ids).to include(category_three.id)
      end

      it 'return error when pass a invalid namespace' do
        get '/inventory/categories', nil, auth(user, 9_999)

        expect(response.status).to be_a_unprocessable_entity

        expect(parsed_body['error']).to eq(I18n.t(:invalid_namespace))
        expect(parsed_body['type']).to eq('invalid_namespace')
      end
    end
  end

  describe 'POST /inventory/categories' do
    let!(:valid_params) do
      {
        title: 'Inventory category',
        plot_format: 'pin',
        color: '#e2e2e2',
        icon: encode64('images/valid_report_category_icon.png')
      }
    end

    it 'creates the category in the current namespace' do
      post '/inventory/categories', valid_params, auth(user, namespace_one.id)

      expect(response.status).to eq(201)
      expect(parsed_body['category']['namespace']['id']).to eq(namespace_one.id)
    end

    it 'creates a global category' do
      valid_params[:global] = true

      post '/inventory/categories', valid_params, auth(user, namespace_one.id)

      expect(response.status).to eq(201)
      expect(parsed_body['category']['namespace']).to be_nil
    end

    it 'return error when pass a invalid namespace' do
      post '/inventory/categories', valid_params, auth(user, 9_999)

      expect(response.status).to be_a_unprocessable_entity

      expect(parsed_body['error']).to eq(I18n.t(:invalid_namespace))
      expect(parsed_body['type']).to eq('invalid_namespace')
    end
  end

  describe 'PUT /inventory/categories/:id' do
    let(:category) { create(:inventory_category) }

    it 'return error when pass a invalid namespace' do
      put "/inventory/categories/#{category.id}", nil, auth(user, 9_999)

      expect(response.status).to be_a_unprocessable_entity

      expect(parsed_body['error']).to eq(I18n.t(:invalid_namespace))
      expect(parsed_body['type']).to eq('invalid_namespace')
    end
  end
end
