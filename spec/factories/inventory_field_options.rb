FactoryGirl.define do
  sequence(:random_option) { |n| "Option #{n}" }

  factory :inventory_field_option, class: 'Inventory::FieldOption' do
    association :field, factory: :inventory_field
    value { generate(:random_option) }
    disabled false

    trait :disabled do
      disabled true
    end
  end
end
