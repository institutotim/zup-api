require 'spec_helper'

describe ExecuteFormulaForItems do
  let!(:user) { create(:user) }
  let!(:formula) { create(:inventory_formula, :with_conditions) }

  describe '#perform' do
    let!(:status) { create(:inventory_status) }
    let!(:item) { create(:inventory_item, category: formula.category, status: status) }

    subject { ExecuteFormulaForItems.new.perform(user.id, formula.id, [item.id]) }

    it 'calls "check_and_update!" on the correct service class instance' do
      service_double = double('inventory__update_status_with_formulas')
      expect(Inventory::UpdateStatusWithFormulas).to receive(:new).with(item, user, [formula]).and_return(service_double)
      expect(service_double).to receive(:check_and_update!)
      subject
    end
  end
end
