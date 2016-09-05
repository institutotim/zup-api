FactoryGirl.define do
  factory :chat_room do
    namespace { Namespace.first_or_create(name: 'Namespace') }

    title 'Título da sala de chat'
  end
end
