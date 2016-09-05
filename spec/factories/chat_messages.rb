FactoryGirl.define do
  factory :chat_message do
    kind 0
    user
    association :chattable, factory: :case
    text 'Um bom dia pra você! :)'

    trait :system_message do
      kind 1
      user nil
    end
  end
end
