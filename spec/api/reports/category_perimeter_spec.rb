require 'app_helper'

describe Reports::CategoryPerimeters::API do
  let(:user)      { create(:user) }
  let(:category)  { create(:reports_category) }
  let(:group)     { create(:group) }
  let(:perimeter) { create(:reports_perimeter) }

  let(:category_perimeter) do
    create(
      :reports_category_perimeter,
      group: group,
      category: category,
      perimeter: perimeter
    )
  end

  context 'POST /reports/categories/:category_id/perimeters' do
    let(:valid_params) do
      {
        group_id: group.id,
        perimeter_id: perimeter.id,
        priority: 10
      }
    end

    subject do
      post "/reports/categories/#{category.id}/perimeters", valid_params, auth(user)
    end

    it 'create a new category perimeter' do
      subject

      expect(response.status).to be_a_requisition_created

      body = parsed_body['perimeter']

      expect(body['id']).to_not be_nil
      expect(body['active']).to be_truthy
      expect(body['priority']).to eq(10)
      expect(body['group']['id']).to eq(group.id)
      expect(body['perimeter']['id']).to eq(perimeter.id)
      expect(body['category']['id']).to eq(category.id)
    end
  end

  describe 'GET /reports/categories/:category_id}/perimeters' do
    let!(:perimeters) do
      create_list(:reports_category_perimeter, 3, category: category)
    end

    subject do
      get "/reports/categories/#{category.id}/perimeters", nil, auth(user)
    end

    it 'return all category perimeters' do
      subject

      expect(response.status).to be_a_success_request

      body = parsed_body['perimeters']

      expect(body.size).to eq(3)
      expect(body.map { |r| r['id'] }).to match_array(perimeters.map(&:id))
    end
  end

  describe 'GET /reports/categories/:category_id/perimeters/:id' do
    subject do
      get "/reports/categories/#{category.id}/perimeters/#{category_perimeter.id}", nil, auth(user)
    end

    it 'returns the category perimeter data' do
      subject

      expect(response.status).to be_a_success_request

      body = parsed_body['perimeter']

      expect(body['id']).to eq(category_perimeter.id)
      expect(body['active']).to be_truthy
      expect(body['priority']).to eq(category_perimeter.priority)
      expect(body['group']['id']).to eq(group.id)
      expect(body['perimeter']['id']).to eq(perimeter.id)
      expect(body['category']['id']).to eq(category.id)
    end
  end

  describe 'PUT /reports/categories/:category_id/perimeters/:id' do
    let(:new_group)              { create(:group) }
    let(:new_perimeter)          { create(:reports_perimeter) }

    let(:valid_params) do
      {
        group_id: new_group.id,
        perimeter_id: new_perimeter.id,
        priority: 15
      }
    end

    subject do
      put "/reports/categories/#{category.id}/perimeters/#{category_perimeter.id}", valid_params, auth(user)
    end

    it 'updates an existent category perimeter' do
      subject

      expect(response.status).to be_a_success_request

      body = parsed_body['perimeter']

      expect(body['id']).to eq(category_perimeter.id)
      expect(body['active']).to be_truthy
      expect(body['priority']).to eq(15)
      expect(body['group']['id']).to eq(new_group.id)
      expect(body['perimeter']['id']).to eq(new_perimeter.id)
      expect(body['category']['id']).to eq(category.id)
    end
  end

  describe 'DELETE /reports/categories/#{category.id}/perimeters/:id' do
    subject do
      delete "/reports/categories/#{category.id}/perimeters/#{category_perimeter.id}", nil, auth(user)
    end

    it 'removes an existent category perimeter' do
      subject

      expect(response.status).to be_a_no_content_request
      expect(Reports::CategoryPerimeter.where(id: category_perimeter.id).first).to be_nil
    end
  end
end
