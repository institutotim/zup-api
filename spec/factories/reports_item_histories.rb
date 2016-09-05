FactoryGirl.define do
  factory :reports_history, class: 'Reports::ItemHistory' do
    action 'Did an action'
    association :user, factory: :user
    association :item, factory: :reports_item

    trait :category do
      kind 'category'
    end

    trait :status do
      kind 'status'
    end
  end
end
