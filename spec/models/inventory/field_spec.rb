require 'app_helper'

describe Inventory::Field do
  context 'validations' do
    let(:field) { create(:inventory_field) }

    it "can't create another field with the same name for the same section" do
      another_field = build(:inventory_field,
                               section: field.section,
                               title: field.title)

      expect(another_field.save).to eq(false)
      expect(another_field.errors.messages).to include(:title)
    end

    context 'inclusion of kind' do
      Inventory::Field::AVAILABLE_KINDS.each do |kind, _klass|
        it "allows the kind #{kind} that is on the list" do
          field = build(:inventory_field, kind: kind)
          expect(field.save).to eq(true)
        end
      end
    end
  end

  context 'scopes' do
    let!(:section) { create(:inventory_section) }
    let!(:fields_not_required) { create_list(:inventory_field, 10, section: section) }
    let!(:fields_required) { create_list(:inventory_field, 10, section: section, required: true) }

    it "'required' returns only required fields" do
      expect(section.fields - (fields_not_required + fields_required)).to eq([])
      expect(section.fields.required - fields_required).to eq([])
    end
  end

  context 'generated title' do
    let(:field) { build(:inventory_field, label: 'Árvores da Rua 1', title: nil) }

    it 'generates a title for the field using the label' do
      expect(field.valid?).to be_truthy
      expect(field.title).to eq('field_arvores_da_rua_1')
    end
  end
end
