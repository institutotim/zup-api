FactoryGirl.define do
  factory :flow do
    title 'title test'
    description 'description test'
    association :created_by, factory: :user
    user
    steps { [build(:step)] }
    initial false
    status 'active'
  end

  factory :flow_without_relation, parent: :flow do
    resolution_states []
    resolution_states_versions { {} }
  end

  factory :flow_without_steps, parent: :flow do
    steps []
    steps_versions { {} }
  end

  factory :flow_with_more_steps, parent: :flow do
    steps { [build(:step), build(:step)] }
  end

  trait :with_resolution_state do
    resolution_states { [build(:resolution_state, default: true)] }
  end
end
