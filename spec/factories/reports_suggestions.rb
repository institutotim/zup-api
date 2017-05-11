FactoryGirl.define do
  factory :reports_suggestion, class: 'Reports::Suggestion' do
    namespace { Namespace.first_or_create(default: true, name: 'Namespace') }

    association :category, factory: :reports_category_with_statuses
    association :item, factory: :reports_item

    address { FFaker::Address.street_address }
    reports_items_ids { [create(:reports_item).id] }
  end
end
