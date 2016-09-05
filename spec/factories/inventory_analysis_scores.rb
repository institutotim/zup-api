FactoryGirl.define do
  factory :inventory_analysis_score, class: 'Inventory::AnalysisScore' do
    association :analysis, factory: :inventory_analysis
    field { analysis.category.fields.sample }
    operator 'equal_to'
    content 'test'
    score(-10)
  end
end
