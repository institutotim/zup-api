require 'app_helper'

describe Inventory::Formula do
  it 'is valid' do
    formula = build(:inventory_formula)
    formula.conditions.build(attributes_for(:inventory_formula_condition, formula: formula))
    expect(formula).to be_valid
  end
end
