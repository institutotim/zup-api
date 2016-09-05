FactoryGirl.define do
  factory :trigger do
    title { generate(:name) }
    trigger_conditions { [build(:trigger_condition)] }
    action_type 'disable_steps'
    action_values [2]
    description { "description #{generate(:name)}" }
    step { Step.last }
    user { User.first }
  end
end
