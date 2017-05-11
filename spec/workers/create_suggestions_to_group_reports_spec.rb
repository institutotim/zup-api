require 'app_helper'

describe CreateSuggestionsToGroupReports do
  let(:category) { create(:reports_category_with_statuses) }

  let!(:report_one) do
    create(:reports_item,
      category: category,
      number: '100',
      address: 'Rua XV de Novembro',
      district: 'Centro',
      postal_code: '12345000'
    )
  end

  let!(:report_two)   do
    create(:reports_item,
      category: category,
      number: '100',
      address: 'Rua 15 de Novembro',
      district: 'Centro',
      postal_code: '12345000'
    )
  end

  let!(:report_three) do
    create(:reports_item,
      category: category,
      number: '100',
      address: 'R. 15 de Novembro',
      district: 'Centro',
      postal_code: '12345000'
    )
  end

  let!(:report_four)  do
    create(:reports_item,
      category: category,
      number: '100',
      address: 'r. xv de novembro',
      district: 'Centro',
      postal_code: '12345000'
    )
  end

  let!(:report_five) do
    create(:reports_item, category: category, address: 'Rua XV de Novembro')
  end

  let!(:report_six) { create(:reports_item, category: category) }

  subject { described_class.new }

  context '#perfom' do
    it 'create a new suggestion based in similarity of reports address' do
      subject.perform

      suggestion = Reports::Suggestion.last
      expected_ids = [report_one.id, report_two.id, report_three.id, report_four.id]
      unexpected_ids = [report_five.id, report_six.id]

      expect(suggestion.reports_items_ids).to match_array(expected_ids)
      expect(suggestion.reports_items_ids).to_not match_array(unexpected_ids)
    end
  end
end
