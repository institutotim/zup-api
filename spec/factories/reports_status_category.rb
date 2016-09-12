FactoryGirl.define do
  factory :reports_status_category, class: 'Reports::StatusCategory' do
    association :category, factory: :reports_category

    status { create(:status) }
    namespace { Namespace.first_or_create(default: true, name: 'Namespace') }

    color '#f8b01d'
    initial false
    final false
    active true
    private false

    trait :initial_status do
      status { create(:initial_status) }
      initial true
    end

    trait :final_status do
      status { create(:final_status) }
      final true
    end

    trait :in_progress_status do
      status { create(:status, title: 'Em andamento') }
      final true
    end

    trait :unsolved_status do
      status { create(:final_status, title: 'Não resolvidas', color: '#999999') }
      final true
    end
  end
end
