require 'app_helper'

describe Export do
  let(:export_report) { build(:export) }
  let(:export_inventory) { build(:export, :inventory) }

  subject { export_report }

  describe 'associations' do
    it { should belong_to(:inventory_category).class_name('Inventory::Category') }
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:kind) }

    context 'inventory' do
      subject { export_inventory }

      it { should validate_presence_of(:inventory_category) }
    end
  end

  describe '#kind_humanize' do
    it { expect(export_report.kind_humanize).to eq('Relatos') }
    it { expect(export_inventory.kind_humanize).to eq('Inventários') }
  end
end
