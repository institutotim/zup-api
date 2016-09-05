FactoryGirl.define do
  factory :inventory_history, class: 'Inventory::ItemHistory' do
    action 'Did an action'
    association :user, factory: :user
    association :item, factory: :inventory_item

    trait :report do
      kind 'report'
    end

    trait :images do
      kind 'images'
    end

    trait :status do
      kind 'status'
    end

    trait :fields do
      kind 'fields'
    end

    trait :flow do
      kind 'flow'
    end
  end
end
