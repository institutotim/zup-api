require 'spec_helper'

describe Reports::Groups::API do
  let(:user)       { create(:user) }
  let(:category)   { create(:reports_category_with_statuses) }

  context 'GET /reports/items/:reports_item_id/group' do
    let!(:report_one) do
      create(:reports_item,
        category: category,
        group_key: 'dbe88426703c499f6ebe6b799f5245ac'
      )
    end

    let!(:report_two) do
      create(:reports_item,
        category: category,
        group_key: 'dbe88426703c499f6ebe6b799f5245ac'
      )
    end

    it 'return all reports grouped' do
      get "/reports/items/#{report_one.id}/group", nil, auth(user)
      expect(response.status).to be_a_success_request

      body = parsed_body['reports']
      expect(body.size).to eq(2)

      returned_ids = body.map { |b| b['id'] }
      expected_ids = [report_one.id, report_two.id]

      expect(returned_ids).to match_array(expected_ids)
    end
  end

  context 'POST /reports/group' do
    let(:report_one) { create(:reports_item, category: category) }
    let(:report_two) { create(:reports_item, category: category) }

    let(:valid_params) do
      { reports_ids: "#{report_one.id},#{report_two.id}" }
    end

    it 'should group all reports' do
      expect_any_instance_of(Reports::GroupItems).to receive(:group!).and_call_original

      post '/reports/group', valid_params, auth(user)

      expect(response.status).to be_a_requisition_created

      message = parsed_body['message']
      report_one.reload
      report_two.reload

      expect(message).to eq('Relatos agrupados com sucesso')
      expect(report_one.group_key).to_not be_nil
      expect(report_two.group_key).to_not be_nil
    end
  end

  context 'DELETE /reports/ungroup' do
    let(:report_one) do
      create(:reports_item,
        category: category,
        group_key: 'dbe88426703c499f6ebe6b799f5245ac'
      )
    end

    let(:valid_params) do
      { reports_ids: report_one.id.to_s }
    end

    it 'should ungroup the reports' do
      expect_any_instance_of(Reports::GroupItems).to receive(:ungroup!).and_call_original

      delete '/reports/ungroup', valid_params, auth(user)

      expect(response.status).to be_a_success_request

      message = parsed_body['message']
      report_one.reload

      expect(message).to eq('Relatos desagrupados com sucesso')
      expect(report_one.group_key).to be_nil
    end
  end
end
