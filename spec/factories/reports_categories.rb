require 'action_dispatch/testing/test_process'

include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :reports_category, class: 'Reports::Category' do
    sequence :title do |n|
      "The #{n}th report category"
    end

    user_response_time 1 * 60 * 60 * 24
    resolution_time 2 * 60 * 60 * 24
    active true
    allows_arbitrary_position false
    color '#f3f3f3'
    priority :high
    icon { fixture_file_upload("#{Application.config.root}/spec/fixtures/images/valid_report_category_icon.png") }
    marker { fixture_file_upload("#{Application.config.root}/spec/fixtures/images/valid_report_category_marker.png") }
    confidential false

    factory :reports_category_with_statuses do
      after(:create) do |category, _|
        namespace = Namespace.first_or_create(default: true, name: 'Namespace')

        status_params = [
          attributes_for(:status, title: 'Em andamento').merge(namespace_id: namespace.id),
          attributes_for(:initial_status).merge(namespace_id: namespace.id),
          attributes_for(:final_status).merge(namespace_id: namespace.id),
          attributes_for(:final_status, title: 'Não resolvidas', color: '#999999').merge(namespace_id: namespace.id)
        ]

        category.update_statuses!(status_params)
      end
    end

    after(:create) do |category, _|
      namespace = Namespace.first_or_create(default: true, name: 'Namespace')
      create(:reports_category_setting, namespace: namespace, category: category)

      Group.guest.each do |group|
        group.permission.reports_items_read_public += [category.id]
        group.save!
      end
    end

    trait :confidential do
      confidential true
    end
  end
end
