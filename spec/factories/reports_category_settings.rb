FactoryGirl.define do
  factory :reports_category_setting, class: 'Reports::CategorySetting' do
    association :category,  factory: :reports_category
    association :namespace, factory: :namespace

    user_response_time 1 * 60 * 60 * 24
    resolution_time 2 * 60 * 60 * 24
    allows_arbitrary_position false
    confidential false
  end
end
