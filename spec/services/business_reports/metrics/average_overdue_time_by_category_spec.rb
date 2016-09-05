require 'app_helper'

describe BusinessReports::Metrics::AverageOverdueTimeByCategory do
  let(:date_range) do
    Date.new(2015, 6, 1)..Date.new(2015, 6, 12)
  end
  let(:search_date_range) do
    date_range.first..(date_range.last + 1.day)
  end

  let(:category1) { create(:reports_category_with_statuses) }
  let(:category2) { create(:reports_category_with_statuses) }
  let(:category3) { create(:reports_category_with_statuses) }

  describe '#fetch_data' do
    let(:categories_ids) { [category1, category2] }

    let!(:reports1) do
      create_list(:reports_item, 1, category: category1, created_at: date_range.first)
    end
    let!(:invalid_reports1) do
      create_list(:reports_item, 2, category: category1, created_at: (date_range.first - 1.day))
    end

    let!(:reports2) do
      create_list(:reports_item, 3, category: category2, created_at: date_range.first)
    end
    let!(:invalid_reports2) do
      create_list(:reports_item, 3, category: category2, created_at: date_range.to_a.sample)
    end

    before do
      reports1.each do |report|
        report.update(overdue: true, overdue_at: report.created_at + 20.days)
      end

      reports2.each do |report|
        report.update(overdue: true, overdue_at: report.created_at + 13.days)
      end
    end

    subject { described_class.new(search_date_range, categories_ids: categories_ids) }

    it 'returns the correct stats' do
      chart_result = subject.fetch_data

      expect(chart_result.data_array).to match_array(
        [
          [category1.title, 20],
          [category2.title, 13]
        ]
      )
    end
  end
end
