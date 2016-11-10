FactoryGirl.define do
  factory :custom_field_data, class: 'Reports::CustomFieldData' do
    association :custom_field
    association :item, factory: :reports_item
  end
end
