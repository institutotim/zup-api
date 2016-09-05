FactoryGirl.define do
  factory :reports_custom_field, class: 'Reports::CustomField' do
    title 'This is a custom field'
    multiline false
  end
end
