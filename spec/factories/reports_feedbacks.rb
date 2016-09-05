FactoryGirl.define do
  factory :reports_feedback, class: 'Reports::Feedback' do
    association :reports_item, factory: :reports_item
    association :user, factory: :user
    kind 'positive'
    content 'Tudo foi arrumado!'
  end
end
