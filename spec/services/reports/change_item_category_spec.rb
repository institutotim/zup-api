require 'spec_helper'

describe Reports::ChangeItemCategory do
  let(:user) { create(:user) }
  let(:item) { create(:reports_item) }
  let(:new_category) { create(:reports_category_with_statuses) }
  let(:new_status) { new_category.statuses.first }

  subject { described_class.new(item, new_category, new_status, user) }

  describe '#process!' do
    before do
      subject.process!
      item.reload
    end

    it 'updates the category' do
      expect(item.category).to eq(new_category)
      expect(item.status).to eq(new_status)
    end
  end
end
