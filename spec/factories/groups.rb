FactoryGirl.define do
  sequence(:name) { |n| "Random name #{n}" }

  factory :group do
    namespace { Namespace.first_or_create(name: 'Namespace') }

    name
    guest false
    association :permission, factory: :group_permission
  end

  factory :group_for_admin, parent: :group do
    association :permission, factory: :admin_permissions
  end

  factory :guest_group, parent: :group do
    association :permission, factory: :group_permission
    guest true
  end
end
