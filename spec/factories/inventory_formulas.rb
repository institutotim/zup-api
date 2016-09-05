FactoryGirl.define do
  factory :inventory_formula, class: 'Inventory::Formula' do
    association :category, factory: :inventory_category_with_sections
    status { create(:inventory_status, category: category) }
    groups_to_alert []

    trait :with_conditions do
      after(:create) do |formula, _evaluator|
        create_list(:inventory_formula_condition, 3, formula: formula)
      end
    end

    trait :with_history do
      after(:create) do |formula, _evaluator|
        create_list(:inventory_formula_history, 3, formula: formula)
      end
    end
  end
end
