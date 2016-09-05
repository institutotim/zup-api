require 'app_helper'

describe Inventory::Section do
  context 'validations' do
    it 'requires the title' do
      section = Inventory::Section.new
      expect(section.save).to eq(false)
      expect(section.errors.messages).to include(:title)
    end
  end

  describe '#disable!' do
    subject { create(:inventory_section_with_fields) }

    it 'marks the section as disabled' do
      expect(subject).to_not be_disabled
      subject.disable!
      expect(subject).to be_disabled
    end

    it 'marks all children fields as disable as well' do
      subject.fields.each do |field|
        expect(field).to_not be_disabled
      end

      subject.disable!

      subject.fields.each do |field|
        expect(field).to be_disabled
      end
    end
  end
end
