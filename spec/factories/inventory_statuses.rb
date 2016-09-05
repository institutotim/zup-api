FactoryGirl.define do
  factory :inventory_status, class: 'Inventory::Status' do
    sequence :title do |n|
      "Status #{n}"
    end
    color '#ff0000'
    association :category, factory: :inventory_category
  end
end
