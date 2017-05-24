require 'app_helper'

describe DeleteMarkedRecords do
  let!(:marked_report_category) { create(:reports_category, :deleted) }
  let!(:report_category)        { create(:reports_category) }

  let!(:marked_inventory_category) { create(:inventory_category, :deleted) }
  let!(:inventory_category)        { create(:inventory_category) }

  subject { described_class.new.perform }

  before(:each) do
    subject
  end

  describe '#perform' do
    it { expect(Reports::Category.find_by(id: marked_report_category.id)).to be_nil }
    it { expect(Reports::Category.find_by(id: report_category.id)).to_not be_nil }
    it { expect(Inventory::Category.find_by(id: marked_inventory_category.id)).to be_nil }
    it { expect(Inventory::Category.find_by(id: inventory_category.id)).to_not be_nil }
  end
end
