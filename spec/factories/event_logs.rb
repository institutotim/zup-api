FactoryGirl.define do
  factory :event_log do
    namespace { Namespace.first_or_create(default: true, name: 'Namespace') }

    association :user
    request_method 'POST'
    headers { { "Version": 'HTTP/1.1', "Host": 'localhost:3000' } }
    url '/reports/3/items'
    request_body { { params: 'sample' } }
  end
end
