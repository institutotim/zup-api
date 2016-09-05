require 'app_helper'

describe Inventory::FormulaAlert do
  describe '#affected_items' do
    let(:formula) { create(:inventory_formula, :with_history) }
    let(:formula_alert) { create(:inventory_formula_alert, formula: formula) }

    it 'return all items' do
      formula.histories.update_all(inventory_formula_alert_id: formula_alert.id)
      expect(formula_alert.affected_items).to eq(formula.histories.map(&:item))
    end
  end
end
