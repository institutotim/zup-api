FactoryGirl.define do
  factory :status, class: 'Reports::Status' do
    sequence :title do |n|
      "Random status #{n}"
    end

    color '#f8b01d'
    initial false
    final false

    factory :initial_status do
      title 'Em Aberto'
      color '#f8b01d'
      initial true
      final false
    end

    factory :final_status do
      title 'Resolvidas'
      color '#78c953'
      initial false
      final true
    end

    trait :with_category do
      ignore do
        category create(:reports_category)
      end

      after(:create) do |status, evaluator|
        create(
          :reports_status_category, status: status, category: evaluator.category
        )
      end
    end
  end
end
