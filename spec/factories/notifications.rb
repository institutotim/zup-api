FactoryGirl.define do
  factory :notification do
    association :user, factory: :user
    association :notificable, factory: :chat_message

    title 'Você foi mencionado'
    description 'Você foi mencionado por fulano'
    read false
  end
end
