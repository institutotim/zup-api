FactoryGirl.define do
  factory :inventory_item, class: 'Inventory::Item' do
    association :category, factory: :inventory_category_with_sections
    association :user, factory: :user

    namespace { Namespace.first_or_create(default: true, name: 'Namespace') }

    before(:create) do |item, _evaluator|
      item.category.fields.each do |field|
        if field.use_options?
          item_data = item.data.build(field: field, content: [])
        else
          item_data = item.data.build(field: field, content: generate(:name))
        end

        if field.location
          latitude, longitude = RandomLocationPoint.location(-23.5505200, -46.6333090, 1)

          if field.title == 'longitude'
            item_data.content = longitude
          elsif field.title == 'latitude'
            item_data.content = latitude
          end
        end
      end
    end

    trait :with_status do
      association :status, factory: :inventory_status
    end
  end
end
