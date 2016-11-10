FactoryGirl.define do
  factory :custom_field, class: 'Reports::CustomField' do
    title { FFaker::Name.name }
  end
end
