require 'app_helper'

describe Inventory::ItemRelationship, :focus do
  context 'validations' do
    subject { build(:inventory_item_relationship) }

    it { should validate_uniqueness_of(:inventory_item_id).scoped_to(:relationship_id) }
    it { should validate_uniqueness_of(:relationship_id).scoped_to(:inventory_item_id) }
  end
end
