require 'app_helper'

describe BusinessReports::Metrics::TotalReportsByStatus do
  let(:date_range) do
    Date.new(2015, 6, 1)..Date.new(2015, 6, 12)
  end
  let(:search_date_range) do
    date_range.first..(date_range.last + 1.day)
  end

  let!(:category1) { create(:reports_category_with_statuses) }
  let!(:category2) { create(:reports_category_with_statuses) }
  let!(:category3) { create(:reports_category_with_statuses) }

  let(:status1) { category1.statuses.first }
  let(:status2) { category2.statuses.last }

  describe '#fetch_data' do
    let(:categories_ids) { [category1, category2] }

    let!(:reports1) do
      create_list(:reports_item, 1, category: category1, created_at: date_range.to_a.sample)
    end

    let!(:reports2) do
      create_list(:reports_item, 3, category: category2, created_at: date_range.to_a.sample)
    end

    subject { described_class.new(search_date_range, categories_ids: categories_ids) }

    before do
      status1.update(title: 'Status 1')
      status2.update(title: 'Status 2')

      reports1.each do |report|
        Reports::UpdateItemStatus.new(report).update_status!(status1)
      end

      reports2.each do |report|
        Reports::UpdateItemStatus.new(report).update_status!(status2)
      end
    end

    it 'returns the correct stats' do
      chart_result = subject.fetch_data

      expect(status1).to_not eq(status2)

      reports1.each do |report|
        expect(report.status).to eq(status1)
      end

      reports2.each do |report|
        expect(report.status).to eq(status2)
      end

      expect(chart_result.data_array).to match_array(
        [
          [status1.title, 1],
          [status2.title, 3]
        ]
      )
    end
  end
end
