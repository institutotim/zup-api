FactoryGirl.define do
  factory :case do
    association :created_by, factory: :user
    association :initial_flow, factory: :flow

    namespace { Namespace.first_or_create(name: 'Namespace') }
  end
end
