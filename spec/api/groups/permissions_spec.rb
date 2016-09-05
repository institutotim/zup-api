require 'app_helper'

describe Groups::Permissions::API do
  let(:user) { create(:user) }
  let(:group) { create(:group) }

  context 'GET /groups/:id/permissions' do
    let(:inventory_category) { create(:inventory_category) }

    before do
      group.permission.update(
        inventories_items_edit: [inventory_category.id],
        inventories_items_read_only: [inventory_category.id],
        reports_full_access: true
      )
    end

    it 'returns all permissions by type and id' do
      get "/groups/#{group.id}/permissions", nil, auth(user)
      expect(response.status).to eq(200)

      expect(parsed_body.size).to eq(2)
      expect(parsed_body.first['permission_type']).to eq('report')
      expect(parsed_body.last['permission_type']).to eq('inventory')
    end
  end

  context 'POST /groups/:id/permissions/:type' do
    let(:type) { 'report' }
    let(:url) { "/groups/#{group.id}/permissions/#{type}" }

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
        post url, valid_params, auth(user)
        expect(response.status).to eq(201)

        group.permission.reload
        expect(group.permission.reports_items_edit).to match_array(objects_ids)
        expect(
          group.permission.reports_items_read_public
        ).to match_array(objects_ids)
      end

      it 'throws an error if the id is non-existent' do
        valid_params[:objects_ids] = [99, 98]
        post url, valid_params, auth(user)

        expect(response.status).to eq(404)
      end

      context 'business_report permission' do
        let(:objects_ids) { create_list(:business_report, 2).map(&:id) }
        let(:permissions) { %w(business_reports_view) }

        it 'adds the ids to the array of ids of the permissions' do
          post "/groups/#{group.id}/permissions/business_report", valid_params, auth(user)
          expect(response.status).to eq(201)

          group.permission.reload
          expect(group.permission.business_reports_view).to match_array(objects_ids)
        end
      end
    end

    context 'boolean permissions' do
      let(:permissions) { ['reports_full_access'] }

      let(:valid_params) do
        {
          permissions: permissions
        }
      end

      it 'sets the permissions as true' do
        post url, valid_params, auth(user)
        expect(response.status).to eq(201)

        group.permission.reload
        expect(group.permission.reports_full_access).to be_truthy
      end
    end
  end

  context 'DELETE /groups/:id/permissions/:type' do
    let(:type) { 'report' }
    let(:url) { "/groups/#{group.id}/permissions/#{type}" }

    context 'permission with object id' do
      let(:object_id) { 1 }
      let(:permission) { 'reports_items_edit' }

      let(:valid_params) do
        {
          object_id: object_id,
          permission: permission
        }
      end

      before do
        group.permission.update(
          permission => [object_id]
        )
      end

      it 'removes the id from the permission' do
        delete url, valid_params, auth(user)
        expect(response.status).to eq(200)

        group.permission.reload
        expect(group.permission.reports_items_edit).to_not include(object_id)
      end
    end

    context 'boolean permissions' do
      let(:permission) { 'reports_full_access' }

      let(:valid_params) do
        {
          permission: permission
        }
      end

      it 'sets the permissions as false' do
        delete url, valid_params, auth(user)
        expect(response.status).to eq(200)

        group.permission.reload
        expect(group.permission.reports_full_access).to be_falsy
      end
    end
  end
end
