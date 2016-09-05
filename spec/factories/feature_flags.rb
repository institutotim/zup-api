FactoryGirl.define do
  sequence(:flag_name) { |n| "flag_#{n}" }

  factory :feature_flag do
    name { generate(:flag_name) }
    status :enabled

    trait :disabled do
      status :disabled
    end
  end
end
