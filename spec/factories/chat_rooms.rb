FactoryGirl.define do
  factory :chat_room do
    namespace { Namespace.first_or_create(default: true, name: 'Namespace') }

    title 'Título da sala de chat'
  end
end
