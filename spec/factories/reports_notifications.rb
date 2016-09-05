FactoryGirl.define do
  factory :reports_notification, class: 'Reports::Notification' do
    association :item, factory: :reports_item
    association :user
    association :notification_type, factory: :reports_notification_type
    deadline_in_days 45
    overdue_at { 45.days.from_now }
    active true

    trait :inactive do
      active false
    end
  end
end
