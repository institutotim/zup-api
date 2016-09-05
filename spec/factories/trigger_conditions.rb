FactoryGirl.define do
  factory :trigger_condition do
    field { Field.last }
    condition_type '=='
    values [1]
    trigger { Trigger.last }
    user { User.first }
  end
end
