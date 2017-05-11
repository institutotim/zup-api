FactoryGirl.define do
  factory :inventory_item_relationship, class: 'Inventory::ItemRelationship' do
    father    { create(:inventory_item) }
    inventory { create(:inventory_item) }
  end
end
