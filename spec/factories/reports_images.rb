FactoryGirl.define do
  factory :report_image, class: 'Reports::Image' do
    image { fixture_file_upload("#{Application.config.root}/spec/fixtures/images/valid_report_category_icon.png") }

    trait :with_photo do
      image { fixture_file_upload("#{Application.config.root}/spec/fixtures/images/valid_report_item_photo.jpg") }
    end
  end
end
