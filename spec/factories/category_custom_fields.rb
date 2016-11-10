FactoryGirl.define do
  factory :category_custom_field, class: 'Reports::CategoryCustomField' do
    association :category, factory: :reports_category
    association :custom_field
  end
end
