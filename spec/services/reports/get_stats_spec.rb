require 'spec_helper'

describe Reports::GetStats  do
  let!(:namespace)       { Namespace.first_or_create(default: true, name: 'Namespace') }
  let!(:report_category) { create(:reports_category_with_statuses) }
  let!(:status)          { report_category.status_categories.final.first.status }

  context 'returning the correct stats' do
    let!(:reports) do
      create_list(:reports_item, 7, category: report_category, status: status, namespace: namespace)
    end

    subject { described_class.new(report_category.id, namespace.id) }

    it 'returns the count of every status on category' do
      returned_stats = subject.fetch

      expect(returned_stats.size).to eq(1)
      expect(returned_stats.first[:statuses].size).to eq(report_category.statuses.count)

      returned_count = returned_stats.first[:statuses].select do |s|
        s[:status_id] == status.id
      end.first[:count]

      expect(returned_count).to eq(7)
    end

    it 'accepts argument as array' do
      returned_stats = described_class.new([report_category.id], namespace.id).fetch

      expect(returned_stats.size).to eq(1)
      expect(returned_stats.first[:statuses].size).to eq(report_category.statuses.count)

      returned_count = returned_stats.first[:statuses].select do |s|
        s[:status_id] == status.id
      end.first[:count]

      expect(returned_count).to eq(7)
    end

    context 'status with same title, different casing' do
      let!(:status2) { create(:status, title: status.title.upcase) }
      let!(:reports_with_other_status) do
        create_list(:reports_item, 4, category: report_category, status: status2)
      end

      let!(:status_category) do
        create(:reports_status_category, category: report_category, status: status2,
               initial: false, final: false)
      end

      before do
        Reports::StatusCategory.where(
          reports_category_id: report_category.id
        ).where.not(
          reports_status_id: [status.id, status2.id]
        ).destroy_all
      end

      it do
        returned_stats = described_class.new([report_category.id], namespace.id).fetch

        expect(returned_stats.size).to eq(1)
        expect(returned_stats.first[:statuses].size).to eq(1)

        returned_count = returned_stats.first[:statuses].select do |s|
          s[:status_id] == status2.id || s[:status_id] == status.id
        end.first[:count]

        expect(returned_count).to eq(11)
      end
    end

    context 'category with subcategories' do
      let!(:subcategory) do
        create(:reports_category_with_statuses, parent_category: report_category)
      end
      let!(:status) do
        subcategory.statuses.where(initial: false).first
      end

      before do
        create_list(:reports_item, 7, category: subcategory, status: status)
      end

      it 'return the right count' do
        returned_stats = subject.fetch

        expect(returned_stats.size).to eq(1)
        expect(returned_stats.first[:statuses].size).to eq(report_category.statuses.count)

        returned_count = returned_stats.first[:statuses].select do |s|
          s[:title] == status.title
        end.first[:count]

        expect(returned_count).to eq(14)
      end
    end
  end

  context 'filtering by date' do
    let!(:reports) do
      reports = create_list(
        :reports_item, 5,
        category: report_category,
        status: status
      )

      reports.each do |report|
        report.update(created_at: DateTime.new(2014, 1, 10))
      end
    end
    let!(:wrong_reports) do
      create_list(
        :reports_item, 10,
        category: report_category,
        status: status
      )
    end
    let(:begin_date) { Date.new(2014, 1, 9).iso8601 }
    let(:end_date) { Date.new(2014, 1, 13).iso8601 }

    it 'the desired reports on the right date range' do
      returned_stats = described_class.new(report_category.id,
                                           namespace.id,
                                           begin_date: begin_date,
                                           end_date: end_date).fetch

      expect(returned_stats.first[:statuses].select do |h|
        h[:status_id] == status.id
      end.first[:count]).to eq(reports.size)
    end
  end
end
