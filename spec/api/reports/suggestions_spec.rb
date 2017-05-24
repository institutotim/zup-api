require 'app_helper'

describe Reports::Suggestions::API do
  let(:user)       { create(:user) }
  let(:category)   { create(:reports_category_with_statuses) }
  let(:report_one) { create(:reports_item, category: category) }
  let(:report_two) { create(:reports_item, category: category) }

  let(:suggestion) do
    create(:reports_suggestion,
      item: report_one,
      category: category,
      reports_items_ids: [report_one.id, report_two.id]
    )
  end

  context 'GET /reports/suggestions' do
    let(:other_category) { create(:reports_category_with_statuses) }

    let!(:suggestions) { create_list(:reports_suggestion, 2, category: category) }
    let!(:suggestion)  { create(:reports_suggestion, category: other_category) }

    it 'return all suggestions' do
      get '/reports/suggestions', nil, auth(user)

      expect(response.status).to be_a_success_request

      body = parsed_body['suggestions']

      expect(body.size).to eq(3)

      body.each do |s|
        expect(s['id']).to_not be_nil
        expect(s['category']).to_not be_nil
        expect(s['reports_items_ids']).to_not be_nil
        expect(s['status']).to_not be_nil
        expect(s['address']).to_not be_nil
      end
    end

    it 'return only suggestion that user can see' do
      allow_any_instance_of(GroupPermission).to receive(:reports_items_group) { true }
      allow_any_instance_of(GroupPermission).to receive(:reports_full_access) { false }
      allow_any_instance_of(UserAbility).to receive(:reports_categories_visible) { [other_category.id] }

      get '/reports/suggestions', nil, auth(user)

      expect(response.status).to be_a_success_request

      body = parsed_body['suggestions']

      expect(body.size).to eq(1)

      returned_suggestion = body.first

      expect(returned_suggestion['id']).to eq(suggestion.id)
      expect(returned_suggestion['category']['id']).to eq(other_category.id)
      expect(returned_suggestion['reports_items_ids']).to eq(suggestion.reports_items_ids)
      expect(returned_suggestion['status']).to eq(suggestion.status)
      expect(returned_suggestion['address']).to eq(suggestion.address)
    end
  end

  context 'PUT /reports/suggestions/:id/ignore' do
    it 'mark the suggestion as ignored' do
      put "/reports/suggestions/#{suggestion.id}/ignore", nil, auth(user)
      expect(response.status).to be_a_success_request

      body = parsed_body['suggestion']

      expect(body['id']).to eq(suggestion.id)
      expect(body['status']).to eq('ignored')
    end
  end

  context 'PUT /reports/suggestions/:id/group' do
    it 'mark the suggestion as grouped and group reports' do
      put "/reports/suggestions/#{suggestion.id}/group", nil, auth(user)
      expect(response.status).to be_a_success_request

      body = parsed_body['suggestion']

      report_one.reload
      report_two.reload

      expect(body['id']).to eq(suggestion.id)
      expect(body['status']).to eq('grouped')

      expect(report_one.group_key).to_not be_nil
      expect(report_two.group_key).to_not be_nil
      expect(report_two.group_key).to eq(report_one.group_key)
    end
  end
end
