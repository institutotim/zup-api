FactoryGirl.define do
  factory :reports_feedback_image, class: 'Reports::FeedbackImage' do
    reports_feedback nil
    image 'MyString'
  end
end
