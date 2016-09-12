FactoryGirl.define do
  factory :reports_category_perimeter, class: 'Reports::CategoryPerimeter' do
    association :category, factory: :reports_category
    association :group
    association :perimeter, factory: :reports_perimeter

    namespace { Namespace.first_or_create(default: true, name: 'Namespace') }
  end
end
