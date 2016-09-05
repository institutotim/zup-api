FactoryGirl.define do
  factory :inventory_analysis, class: 'Inventory::Analysis' do
    association :category, factory: :inventory_category_with_sections
    sequence(:title) { |n| "Analysis #{n}" }
    expression '10'

    factory :inventory_analysis_with_scores do
      after(:create) do |analysis, _evaluator|
        scores = create_list(:inventory_analysis_score, 3, analysis: analysis)
        scores.map(&:id).join(' + ')
      end
    end
  end
end
