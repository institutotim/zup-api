FactoryGirl.define do
  factory :reports_item_status_history, class: 'Reports::ItemStatusHistory' do
    reports_item_id 1
    previous_status_id 1
    new_status_id 1
  end
end
