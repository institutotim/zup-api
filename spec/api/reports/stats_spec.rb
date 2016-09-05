require 'spec_helper'

describe Reports::Stats::API do
  let(:user) { create(:user) }
  let!(:report_category) { create(:reports_category_with_statuses) }
  let!(:status) { report_category.statuses.where(initial: false).first }
  let!(:reports) do
    create_list(:reports_item, 7, category: report_category, status: status)
  end
  let!(:wrong_reports) do
    create_list(:reports_item, 10, status: status)
  end
  let(:valid_params) do
    Oj.load <<-JSON
      {
        "category_id": #{report_category.id}
      }
    JSON
  end

  it 'returns correct stats' do
    get '/reports/stats', valid_params, auth(user)
    expect(response.status).to eq(200)
    body = parsed_body

    expect(body).to include('stats')
    expect(body['stats'].size).to eq(1)
    expect(body['stats'].first['statuses'].size).to eq(report_category.statuses.count)

    returned_count = body['stats'].first['statuses'].select do |s|
      s['status_id'] == status.id
    end.first['count']

    expect(returned_count).to eq(7)
  end

  it 'accepts no arguments and return all categories stats' do
    get '/reports/stats', nil, auth(user)
    expect(response.status).to eq(200)
    body = parsed_body

    expect(body['stats'].size).to eq(Reports::Category.count)
  end

  context 'with private status' do
    let!(:status) { create(:status) }

    let!(:status_category) do
      create(:reports_status_category, category: report_category, status: status,
             private: true)
    end

    it "doesn't return the private status" do
      get '/reports/stats', valid_params, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body

      expect(body).to include('stats')
      expect(body['stats'].size).to eq(1)
      expect(body['stats'].first['statuses'].size).to eq(report_category.statuses.count - 1)

      returned_status = body['stats'].first['statuses'].select do |s|
        s['status_id'] == status.id
      end.first

      expect(returned_status).to be_nil
    end
  end
end
