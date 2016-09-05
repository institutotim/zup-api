FactoryGirl.define do
  factory :inventory_item_data, class: 'Inventory::ItemData' do
    association :item, factory: :inventory_item
    association :field, factory: :inventory_field
    content { generate(:name) }
  end
end
