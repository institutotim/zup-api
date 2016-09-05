require 'spec_helper'

describe Inventory::FormulaValidator do
  context 'validations' do
    let!(:category) { create(:inventory_category_with_sections) }
    let(:item) { create(:inventory_item, category: category) }
    let(:formula) do
      create(
        :inventory_formula,
        category: category
      )
    end

    context 'equal_to' do
      let!(:field) do
        create(
          :inventory_field,
          kind: 'text',
          section: category.sections.sample
        )
      end

      let!(:condition) do
        create(
          :inventory_formula_condition,
          operator: 'equal_to',
          content: 'test',
          conditionable: field,
          formula: formula
        )
      end

      subject { described_class.new(item, formula) }

      it 'returns true if content is equal' do
        item.data.find_by(field: field).update(content: 'test')
        item.reload.represented_data
        expect(subject.valid?).to eq(true)
      end

      it 'returns false if content is different' do
        item.data.find_by(field: field).update(content: 'testa')
        item.reload.represented_data
        expect(subject.valid?).to eq(false)
      end

      context 'field with selected option' do
        let(:field_option) do
          create(:inventory_field_option, value: 'test')
        end

        before do
          field.update(
            kind: 'radio',
            field_options: [field_option]
          )
        end

        it 'returns true if content is equal' do
          condition.update(content: field_option.id)
          item.data.find_by(field: field).update(selected_options: [field_option])
          item.reload.represented_data
          expect(subject.valid?).to eq(true)
        end
      end
    end

    context 'greater_than' do
      let!(:field) do
        create(
          :inventory_field,
          kind: 'integer',
          section: category.sections.sample
        )
      end

      let!(:condition) do
        create(
          :inventory_formula_condition,
          operator: 'greater_than',
          content: '20',
          conditionable: field,
          formula: formula
        )
      end

      subject { described_class.new(item, formula) }

      it 'returns true if content is greater than' do
        item.data.find_by(field: field).update(content: 30)
        item.reload.represented_data
        expect(subject.valid?).to eq(true)
      end

      it 'returns false if content is lesser than' do
        item.data.find_by(field: field).update(content: 20)
        item.reload.represented_data
        expect(subject.valid?).to eq(false)
      end
    end

    context 'lesser_than' do
      let!(:field) do
        create(
          :inventory_field,
          kind: 'integer',
          section: category.sections.sample
        )
      end

      let!(:condition) do
        create(
          :inventory_formula_condition,
          operator: 'lesser_than',
          content: '20',
          conditionable: field,
          formula: formula
        )
      end

      subject { described_class.new(item, formula) }

      it 'returns true if content is lesser than' do
        item.data.find_by(field: field).update(content: 19)
        item.reload.represented_data
        expect(subject.valid?).to eq(true)
      end

      it 'returns false if content is greater than' do
        item.data.find_by(field: field).update(content: 21)
        item.reload.represented_data
        expect(subject.valid?).to eq(false)
      end
    end

    context 'different' do
      let!(:field) do
        create(
          :inventory_field,
          kind: 'text',
          section: category.sections.sample
        )
      end

      let!(:condition) do
        create(
          :inventory_formula_condition,
          operator: 'different',
          content: 'test',
          conditionable: field,
          formula: formula
        )
      end

      subject { described_class.new(item, formula) }

      it 'returns true if content is different' do
        item.data.find_by(field: field).update(content: 'testa')
        item.reload.represented_data
        expect(subject.valid?).to eq(true)
      end

      it 'returns false if content is equal' do
        item.data.find_by(field: field).update(content: 'test')
        item.reload.represented_data
        expect(subject.valid?).to eq(false)
      end
    end

    context 'between' do
      let!(:field) do
        create(
          :inventory_field,
          kind: 'text',
          section: category.sections.sample
        )
      end

      let!(:condition) do
        create(
          :inventory_formula_condition,
          operator: 'between',
          content: ['test', 'a', 'b'],
          conditionable: field,
          formula: formula
        )
      end

      subject { described_class.new(item, formula) }

      it 'returns true if content satisfies the values' do
        item.data.find_by(field: field).update(content: 'a')
        item.reload.represented_data
        expect(subject.valid?).to eq(true)
      end

      it "returns false if content doesn't satisfies" do
        item.data.find_by(field: field).update(content: 'c')
        item.reload.represented_data
        expect(subject.valid?).to eq(false)
      end
    end

    context 'includes' do
      let!(:field) do
        create(
          :inventory_field,
          kind: 'text',
          section: category.sections.sample
        )
      end

      let!(:condition) do
        create(
          :inventory_formula_condition,
          operator: 'includes',
          content: 'tes',
          conditionable: field,
          formula: formula
        )
      end

      subject { described_class.new(item, formula) }

      it 'returns true if content satisfies the values' do
        item.data.find_by(field: field).update(content: 'test')
        item.reload.represented_data
        expect(subject.valid?).to eq(true)
      end

      it "returns false if content doesn't satisfies" do
        item.data.find_by(field: field).update(content: 'text')
        item.reload.represented_data
        expect(subject.valid?).to eq(false)
      end

      context 'field with selected option' do
        let(:field_option) do
          create(:inventory_field_option)
        end
        let(:other_field_option) do
          create(:inventory_field_option)
        end

        before do
          field.update(
            kind: 'radio',
            field_options: [field_option]
          )
        end

        it 'returns true if content is equal' do
          condition.update(content: [field_option.id])
          item.data.find_by(field: field).update(
            selected_options: [field_option, other_field_option]
          )
          item.reload.represented_data
          expect(subject.valid?).to eq(true)
        end
      end
    end
  end
end
