FactoryGirl.define do
  factory :namespace do
    name { FFaker::Name.name }
  end
end
