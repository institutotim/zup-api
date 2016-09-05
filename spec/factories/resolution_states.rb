FactoryGirl.define do
  factory :resolution_state do
    title { generate(:name) }
    default false
    active true
    flow
    user
  end
end
