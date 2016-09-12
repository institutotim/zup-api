FactoryGirl.define do
  sequence(:password) { SecureRandom.hex[0..8] }

  factory :user do
    namespace { Namespace.first_or_create(default: true, name: 'Namespace') }

    email { FFaker::Internet.email }
    password
    password_confirmation { password }

    name { FFaker::Name.name }
    phone '11912231545'
    commercial_phone '11912231545'
    skype { FFaker::Internet.user_name }
    document { Faker::CPF.numeric }
    birthdate { Date.new(1990, 10, 10) }
    address { FFaker::Address.street_address }
    address_additional { FFaker::Address.secondary_address }
    postal_code '04005000'
    district { FFaker::AddressBR.neighborhood }
    city { FFaker::AddressBR.city }

    institution { FFaker::Company.name }
    position { FFaker::Company.position }

    groups do
      [
        Group.find_by(name: 'Admins') || create(:group_for_admin, name: 'Admins'),
        Group.guest.first || create(:guest_group, name: 'Guest')
      ]
    end

    trait :disabled do
      disabled true
    end

    trait :with_device_configuration do
      device_token { SecureRandom.hex }
      device_type 'ios'
    end
  end

  factory :guest_user, parent: :user do
    groups { [create(:guest_group, name: 'Guest')] }
  end

  factory :service, class: 'User' do
    association :permission, factory: :admin_permissions

    name { FFaker::Name.name }
    kind 1

    trait :guest do
      association :permission, factory: :group_permission
    end
  end
end
