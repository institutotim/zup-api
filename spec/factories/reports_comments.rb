FactoryGirl.define do
  factory :reports_comment, class: 'Reports::Comment' do
    association :item, factory: :reports_item
    association :author, factory: :user
    visibility { Reports::Comment::PUBLIC }
    message 'This is a test comment'

    trait :public do
      visibility Reports::Comment::PUBLIC
    end

    trait :private do
      visibility Reports::Comment::PRIVATE
    end

    trait :internal do
      visibility Reports::Comment::INTERNAL
    end
  end
end
