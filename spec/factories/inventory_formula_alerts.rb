FactoryGirl.define do
  factory :inventory_formula_alert, class: 'Inventory::FormulaAlert' do
    association :formula, factory: :inventory_formula
    groups_alerted []

    trait :sent do
      sent_at { Time.now }
    end
  end
end
