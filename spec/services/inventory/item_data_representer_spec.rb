require 'spec_helper'

describe Inventory::ItemDataRepresenter do
  let!(:item) { create(:inventory_item) }
  let(:category) { item.category }

  subject { described_class.factory(item) }

  describe '#initialize' do
    it 'for each field title, it creates an attribute' do
      category.fields.each do |field|
        expect { subject.send(field.title) }.to_not raise_error
      end
    end

    it "populates data from item's item data relationship" do
      item.data.each do |item_data|
        expect(subject.send(item_data.field.title)).to eq(item_data.content)
      end
    end
  end

  describe '#attributes=' do
    let(:random_field) { category.fields.where(kind: 'text').sample }

    it 'changes the value of the accessor' do
      test_data = 'Test'

      expect(subject.send(random_field.title)).to_not eq(test_data)
      subject.attributes = { random_field.id => test_data }
      expect(subject.send(random_field.title)).to eq(test_data)
    end

    it "raises error if field doesn't exists" do
      expect do
        subject.attributes = { 123123141 => 'Test' }
      end.to raise_error
    end

    context 'disabled fields' do
      let!(:disabled_field) { create(:inventory_field, section: category.sections.first, disabled: true) }

      it 'ignore disabled fields' do
        klass = described_class.factory(item.reload)

        klass.attributes = { disabled_field.id => 'Edited Data' }
        expect(klass.send(disabled_field.title)).to_not eq('Edited Data')
      end
    end

    context 'converting data types' do
      let(:random_field) { category.fields.sample }
      before do
        random_field.update(kind: 'integer')
      end

      it 'converts the content to specified class' do
        test_data = '10'
        subject.attributes = { random_field.id => test_data }
        expect(subject.send(random_field.title)).to eq(10)
      end
    end
  end

  describe '#inject_to_data!' do
    context 'updates the item_data instance' do
      let(:random_field) { category.fields.where(kind: 'text').sample }
      let(:test_data) { 'Test' }

      before do
        subject.attributes = { random_field.id => test_data }
      end

      it 'changes the value of existant item_datas of the item' do
        item_data_of_field = item.data.select { |id| id.field == random_field }.first

        expect(item_data_of_field.content).to_not eq(test_data)

        subject.inject_to_data!

        expect(item_data_of_field.content).to eq(test_data)
      end

      it "if the item data doesn't exists, build it" do
        subject

        item_data_of_field = item.data.select { |id| id.field == random_field }.first
        item_data_of_field.destroy
        item.reload

        subject.inject_to_data!

        item_data_of_field = item.data.select { |id| id.field == random_field }.first
        expect(item_data_of_field).to_not be_nil
        expect(item_data_of_field).to_not be_persisted
      end
    end

    context "validates field's requirement" do
      let(:random_field) { category.fields.sample }

      context 'with integer type' do
        let(:test_data) { '20' }
        context 'maximum' do
          before do
            random_field.update(kind: 'integer', maximum: 10)
            subject.attributes = { random_field.id => test_data }
          end

          it "returns false because of the field's type" do
            expect(subject.inject_to_data!).to be_falsy
            expect(subject.errors).to include(random_field.title.to_sym)
          end
        end

        context 'minimum' do
          before do
            random_field.update(kind: 'integer', minimum: 30)
            subject.attributes = { random_field.id => test_data }
          end

          it "returns false because of the field's type" do
            expect(subject.inject_to_data!).to be_falsy
            expect(subject.errors).to include(random_field.title.to_sym)
          end
        end

        context "if it's not required" do
          before do
            random_field.update(kind: 'integer', minimum: 30, required: false)
            subject.attributes = { random_field.id => '' }
          end

          it 'returns true and no error' do
            subject.inject_to_data!
            expect(subject.errors).to_not include(random_field.title.to_sym)
          end
        end
      end

      context 'with float type' do
        let(:test_data) { '20.3' }
        context 'maximum' do
          before do
            random_field.update(kind: 'decimal', maximum: 20)
            subject.attributes = { random_field.id => test_data }
          end

          it "returns false because of the field's type" do
            expect(subject.inject_to_data!).to be_falsy
            expect(subject.errors).to include(random_field.title.to_sym)
          end
        end

        context 'minimum' do
          before do
            random_field.update(kind: 'decimal', minimum: 21)
            subject.attributes = { random_field.id => test_data }
          end

          it "returns false because of the field's type" do
            expect(subject.inject_to_data!).to be_falsy
            expect(subject.errors).to include(random_field.title.to_sym)
          end
        end
      end

      context 'with string type' do
        let(:test_data) { 'estevao.am@gmail.com' }

        context 'maximum' do
          before do
            random_field.update(kind: 'email', maximum: 4)
            subject.attributes = { random_field.id => test_data }
          end

          it "returns false because of the field's type" do
            expect(subject.inject_to_data!).to be_falsy
            expect(subject.errors).to include(random_field.title.to_sym)
          end
        end

        context 'minimum' do
          before do
            random_field.update(kind: 'email', minimum: 21)
            subject.attributes = { random_field.id => test_data }
          end

          it "returns false because of the field's type" do
            expect(subject.inject_to_data!).to be_falsy
            expect(subject.errors).to include(random_field.title.to_sym)
          end
        end
      end
    end
  end
end
