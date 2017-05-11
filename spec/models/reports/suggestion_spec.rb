require 'app_helper'

describe Reports::Suggestion do
  let(:report) { create(:reports_item) }

  let(:suggestion) do
    create(:reports_suggestion, item: report, reports_items_ids: [report.id])
  end

  context 'associations' do
    it { should belong_to(:category).class_name('Reports::Category') }
    it { should belong_to(:item).class_name('Reports::Item') }
  end

  context 'validations' do
    subject { build(:reports_suggestion) }

    it { should validate_presence_of(:address) }
    it { should validate_presence_of(:reports_category_id) }
    it { should validate_presence_of(:reports_item_id) }
    it { should validate_presence_of(:reports_items_ids) }

    it 'should validate uniqueness of suggestion' do
      expect(suggestion.valid?).to be_truthy

      new_suggestion = build(:reports_suggestion,
        item: report,
        reports_items_ids: [report.id]
      )

      expect(new_suggestion.valid?).to be_falsy
      expect(new_suggestion.errors.messages).to include(reports_items_ids: ['já está em uso'])
    end
  end
end
