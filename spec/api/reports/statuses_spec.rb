require 'spec_helper'

describe Reports::Statuses::API do
  let(:user) { create(:user) }
  let(:category) { create(:reports_category_with_statuses) }

  describe 'GET /reports/categories/:category_id/statuses' do
    before do
      get "/reports/categories/#{category.id}/statuses", nil, auth(user)
    end

    it "returns all the category's statuses" do
      expect(parsed_body['statuses'].map do |s|
        s['id']
      end).to match_array(category.statuses.map(&:id))
    end
  end

  describe 'POST /reports/categories/:category_id/statuses'  do
    context 'with valid params do' do
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "title": "Test status",
            "color": "#440033",
            "initial": true,
            "final": false,
            "active": false
          }
        JSON
      end

      before do
        post "/reports/categories/#{category.id}/statuses", valid_params, auth(user)
      end

      it 'creates the new status' do
        created_status = category.statuses.where(title: valid_params['title']).first
        sc = category.status_categories.find_by(reports_status_id: created_status.id)

        expect(response.status).to eq(201)

        status = valid_params
        expect(created_status.title).to eq(status['title'])
        expect(sc.initial).to eq(status['initial'])
        expect(sc.final).to eq(status['final'])
        expect(sc.active).to eq(status['active'])
        expect(sc.color).to eq(status['color'])
        expect(sc.namespace_id).to eq(user.namespace_id)
      end
    end
  end

  describe 'PUT /reports/categories/:category_id/statuses/:id' do
    let!(:status) { create(:status, :with_category, category: category) }

    context 'with valid params do' do
      let(:valid_params) do
        Oj.load <<-JSON
          {
            "title": "Test status",
            "color": "#440033",
            "initial": true,
            "final": false,
            "active": false,
            "private": false
          }
        JSON
      end

      before do
        put "/reports/categories/#{category.id}/statuses/#{status.id}", valid_params, auth(user)
      end

      it 'creates the new status' do
        expect(response.status).to eq(200)

        created_status = category.statuses.find_by(title: valid_params['title'])
        sc = category.status_categories.find_by(reports_status_id: created_status.id)

        expect(sc.private).to eq(valid_params['private'])
        expect(sc.initial).to eq(valid_params['initial'])
        expect(sc.final).to eq(valid_params['final'])
        expect(sc.active).to eq(valid_params['active'])
        expect(sc.namespace_id).to eq(user.namespace_id)
      end
    end
  end

  describe 'PUT /reports/categories/:category_id/statuses/:id/enable'  do
    let!(:status) { create(:status, :with_category, category: category) }

    before do
      status.update!(active: false)
    end

    it 'creates the new status' do
      put "/reports/categories/#{category.id}/statuses/#{status.id}/enable", nil, auth(user)
      sc = category.status_categories.find_by(reports_status_id: status.id)

      expect(response.status).to eq(200)
      expect(sc.active).to be_truthy
    end
  end

  describe 'DELETE /reports/categories/:category_id/statuses/:id'  do
    let!(:status) { create(:status, :with_category, category: category) }

    it 'deletes status' do
      delete "/reports/categories/#{category.id}/statuses/#{status.id}", nil, auth(user)
      sc = category.status_categories.find_by(reports_status_id: status.id)

      expect(response.status).to eq(200)
      expect(sc.active).to be_falsy
    end
  end
end
