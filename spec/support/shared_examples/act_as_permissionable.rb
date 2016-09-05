RSpec.shared_examples 'act as permissionable' do |namespace, factory|
  let!(:user)       { create(:user) }
  let!(:permission) { create(:group_permission) }
  let!(:model)      { create(factory, permission: permission) }

  context 'GET /permissions/:resource_type/:resource_id' do
    let(:inventory_category) { create(:inventory_category) }

    before do
      model.permission.update(
        inventories_items_edit: [inventory_category.id],
        inventories_items_read_only: [inventory_category.id],
        reports_full_access: true
      )
    end

    it 'returns all permissions by type and id' do
      get "/permissions/#{namespace}/#{model.id}", nil, auth(user)

      expect(response.status).to eq(200)

      expect(parsed_body.size).to eq(2)
      expect(parsed_body.last['permission_type']).to eq('inventory')
      expect(parsed_body.first['permission_type']).to eq('report')
    end
  end

  context 'POST /permissions/:resource_type/:resource_id/:type' do
    let(:type) { 'report' }
    let(:url)  { "/permissions/#{namespace}/#{model.id}/#{type}" }

    subject { post url, valid_params, auth(user) }

    context 'array permissions' do
      let(:objects_ids) { create_list(:reports_category, 2).map(&:id) }
      let(:permissions) { %w(reports_items_edit reports_items_read_public) }

      let(:valid_params) do
        {
          objects_ids: objects_ids,
          permissions: permissions
        }
      end

      it 'adds the ids to the array of ids of the permissions' do
        subject
        expect(response.status).to eq(201)

        permission.reload

        expect(permission.reports_items_edit).to match_array(objects_ids)
        expect(permission.reports_items_read_public).to match_array(objects_ids)
      end

      it 'throws an error if the id is non-existent' do
        valid_params[:objects_ids] = [10_001, 10_002]

        subject

        expect(response.status).to eq(404)
      end
    end

    context 'boolean permissions' do
      let(:valid_params) do
        {
          permissions: ['reports_full_access']
        }
      end

      it 'sets the permissions as true' do
        subject
        expect(response.status).to eq(201)

        permission.reload
        expect(permission.reports_full_access).to be_truthy
      end
    end
  end

  context 'DELETE /permissions/:resource_type/resource_:id/:type' do
    let(:type) { 'report' }
    let(:url) { "/permissions/#{namespace}/#{model.id}/#{type}" }

    subject { delete url, valid_params, auth(user) }

    context 'permission with object id' do
      let(:valid_params) do
        {
          object_id: 1,
          permission: 'reports_items_edit'
        }
      end

      before do
        model.permission.update(
          'reports_items_edit' => [1]
        )
      end

      it 'removes the id from the permission' do
        subject

        expect(response.status).to eq(200)

        permission.reload
        expect(permission.reports_items_edit).to_not include(1)
      end
    end

    context 'boolean permissions' do
      let(:valid_params) do
        {
          permission: 'reports_full_access'
        }
      end

      it 'sets the permissions as false' do
        subject

        expect(response.status).to eq(200)

        permission.reload
        expect(permission.reports_full_access).to be_falsy
      end
    end
  end
end
