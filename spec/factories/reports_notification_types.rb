FactoryGirl.define do
  factory :reports_notification_type, class: Reports::NotificationType do
    association :category, factory: :reports_category_with_statuses

    namespace { Namespace.first_or_create(name: 'Namespace') }

    title 'Notificação 1'
    order 0
    default_deadline_in_days 45
    layout ''

    after(:create) do |notification_type, _evaluator|
      status = create(:status, :with_category, category: notification_type.category)
      notification_type.update!(status: status)
      notification_type
    end
  end
end
