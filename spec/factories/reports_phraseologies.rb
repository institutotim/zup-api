FactoryGirl.define do
  factory :reports_phraseology, class: 'Reports::Phraseology' do
    namespace { Namespace.first_or_create(default: true, name: 'Namespace') }

    title { FFaker::Lorem.word }
    description { FFaker::Lorem.phrase }

    trait :with_category do
      association :category, factory: :reports_category
    end
  end
end
