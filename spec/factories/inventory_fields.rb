FactoryGirl.define do
  factory :inventory_field, class: 'Inventory::Field' do
    sequence :title do |n|
      "field#{n}"
    end
    kind 'text'
    size 'M'
    position 0
    section { create(:inventory_section) }
    options ''
    permissions ''
    required false
  end
end
