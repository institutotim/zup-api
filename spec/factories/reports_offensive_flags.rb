FactoryGirl.define do
  factory :reports_offensive_flag, class: 'Reports::OffensiveFlag' do
    association :item, factory: :reports_item
    association :user, factory: :user
  end
end
