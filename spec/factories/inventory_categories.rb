FactoryGirl.define do
  factory :inventory_category, class: 'Inventory::Category' do
    title { generate(:name) }
    description 'A cool category'
    plot_format 'pin'
    color '#f2f2f2'
    require_item_status false

    icon { fixture_file_upload("#{Application.config.root}/spec/fixtures/images/valid_report_category_icon.png") }
    marker { fixture_file_upload("#{Application.config.root}/spec/fixtures/images/valid_report_category_marker.png") }
    pin { fixture_file_upload("#{Application.config.root}/spec/fixtures/images/valid_report_category_marker.png") }

    after(:create) do |category, _|
      Group.guest.each do |group|
        group.permission.inventories_items_read_only += [category.id]
        group.save!
      end
    end

    factory :inventory_category_with_sections do
      after(:create) do |category, _evaluator|
        create_list(:inventory_section_with_fields, 3, category: category)
      end
    end

    trait :deleted do
      deleted_at 45.days.ago
    end
  end
end
