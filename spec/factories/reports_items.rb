FactoryGirl.define do
  factory :reports_item, class: 'Reports::Item' do
    namespace { Namespace.first_or_create(name: 'Namespace') }

    position do
      RGeo::Geographic.simple_mercator_factory.point(
        *RandomLocationPoint.location(-23.5505200, -46.6333090, 100).reverse
      )
    end

    address { FFaker::Address.street_address }
    number { FFaker::Address.building_number }
    reference 'Perto da padaria'
    district { FFaker::AddressBR.neighborhood }
    city { FFaker::AddressBR.city }
    state { FFaker::AddressBR.state }
    country { FFaker::AddressBR.country }
    description 'Aconteceu algo de ruim por aqui'

    association :category, factory: :reports_category_with_statuses
    association :user, factory: :user

    trait :with_feedback do
      after(:create) do |reports_item, _|
        create(:reports_feedback,
               reports_item: reports_item,
               user: reports_item.user)
      end
    end

    factory :reports_item_with_images do
      after(:create) do |reports_item, _|
        create_list(:report_image, 2, item: reports_item)
      end
    end

    trait :overdue do
      overdue true
    end

    trait :offensive do
      offensive true
    end
  end
end
