# encoding: utf-8
require 'app_helper'

describe Inventory::Category do
  context 'validations' do
    it 'requires title' do
      category = Inventory::Category.new
      expect(category.save).to eq(false)
      expect(category.errors.messages).to include(:title)
    end

    it 'requires uniqueness of title' do
      category = create(:inventory_category)
      category = Inventory::Category.new(title: category.title)
      expect(category.save).to eq(false)
      expect(category.errors.messages).to include(:title)
    end
  end

  context 'default sections' do
    let(:category) { create(:inventory_category) }

    it 'creates the default localization section' do
      expect(category.sections.first.title).to eq('Localização')
      section = category.sections.first

      expect(section.fields.size).to eq(9)
      expect(section.fields.map(&:title)).to \
        include('latitude', 'longitude', 'address',
                'district', 'city', 'state', 'codlog',
                'road_classification', 'postal_code'
               )
    end
  end

  context 'set up default data' do
    let(:category) { build(:inventory_category) }

    it 'set up the `require_item_status` to false if nil' do
      category.require_item_status = nil
      expect(category.valid?).to be_truthy
      expect(category.require_item_status).to eq(false)
    end
  end
end
