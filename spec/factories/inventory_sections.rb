FactoryGirl.define do
  factory :inventory_section, class: 'Inventory::Section' do
    title { generate(:name) }
    category { create(:inventory_category) }
    permissions {}
    required false
    position 0

    factory :inventory_section_with_fields do
      after(:create) do |section, _evaluator|
        create_list(:inventory_field, 2, section: section)
      end
    end
  end
end
