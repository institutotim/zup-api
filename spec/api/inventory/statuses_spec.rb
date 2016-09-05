require 'spec_helper'

describe Inventory::Statuses do
  let(:user) { create(:user) }

  describe 'GET /inventory/categories/:category_id/statuses' do
    let!(:category) { create(:inventory_category) }
    let!(:statuses) { create_list(:inventory_status, 10, category: category) }

    before do
      get "/inventory/categories/#{category.id}/statuses", nil, auth(user)
    end

    it "return all category's statuses" do
      expect(parsed_body['statuses'].map { |s| s['id'] }).to match_array(statuses.map(&:id))
    end
  end

  describe 'POST /inventory/categories/:category_id/statuses' do
    let!(:category) { create(:inventory_category) }
    let(:valid_params) do
      Oj.load <<-JSON
        {
          "title": "Test title",
          "color": "#ff2345"
        }
      JSON
    end

    before do
      post "/inventory/categories/#{category.id}/statuses", valid_params, auth(user)
    end

    it 'returns the created status' do
      returned_status = parsed_body['status']
      expect(returned_status['title']).to eq(valid_params['title'])
      expect(returned_status['color']).to eq(valid_params['color'])

      expect(category.reload.statuses.last.id).to eq(returned_status['id'])
    end
  end

  describe 'PUT /inventory/categories/:category_id/statuses/:id' do
    let!(:category) { create(:inventory_category) }
    let!(:status) { create(:inventory_status, category: category) }
    let(:valid_params) do
      Oj.load <<-JSON
        {
          "title": "Test title",
          "color": "#ff2345"
        }
      JSON
    end

    before do
      put "/inventory/categories/#{category.id}/statuses/#{status.id}", valid_params, auth(user)
    end

    it 'returns the created status' do
      returned_status = parsed_body['status']
      expect(returned_status['title']).to eq(valid_params['title'])
      expect(returned_status['color']).to eq(valid_params['color'])

      expect(category.reload.statuses.last.id).to eq(returned_status['id'])
    end
  end
end
