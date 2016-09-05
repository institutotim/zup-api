require 'app_helper'

describe BusinessReports::Metrics::TotalReportsUnassignedToUser do
  let(:date_range) do
    Date.new(2015, 6, 1)..Date.new(2015, 6, 12)
  end
  let(:search_date_range) do
    date_range.first..(date_range.last + 1.day)
  end

  let(:group) { create(:group) }
  let(:user) { create(:user) }

  let(:category1) { create(:reports_category_with_statuses, default_solver_group_id: 2) }
  let(:category2) { create(:reports_category_with_statuses, default_solver_group_id: 2) }
  let(:category3) { create(:reports_category_with_statuses) }

  describe '#fetch_data' do
    let(:categories_ids) { [category1, category2] }

    let!(:assigned_reports1) do
      create(:reports_item, category: category1, assigned_group: group, created_at: date_range.to_a.sample)
    end
    let!(:invalid_reports1) do
      create_list(:reports_item, 2, category: category1, assigned_user: user, created_at: (date_range.first - 1.day))
    end

    let!(:assigned_reports2) do
      create_list(:reports_item, 3, category: category2, assigned_group: group, created_at: date_range.to_a.sample)
    end
    let!(:invalid_reports2) do
      create_list(:reports_item, 3, category: category2, assigned_user: user, created_at: (date_range.first - 1.day))
    end

    subject { described_class.new(search_date_range, categories_ids: categories_ids) }

    it 'returns the correct stats' do
      chart_result = subject.fetch_data

      expect(chart_result.data_array).to match_array(
        [
          [category1.title, 1],
          [category2.title, 3]
        ]
      )
    end
  end
end
