FactoryGirl.define do
  factory :export do
    namespace { Namespace.first_or_create(default: true, name: 'Namespace') }

    user
    kind 0
    status 0

    trait :inventory do
      inventory_category
      kind 1
    end
  end
end
