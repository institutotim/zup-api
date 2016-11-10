require 'app_helper'

describe Case do
  it { should have_one(:report_item).class_name('Reports::Item') }

  context 'entity' do
    describe '#custom_fields' do
      context 'with report item' do
        it 'returns custom fieds name with value' do
          kase = FactoryGirl.create :case
          report_item = FactoryGirl.create :reports_item, case: kase

          custom_field_data = FactoryGirl.create(
            :custom_field_data,
            item: report_item,
            value: 'Valor customizado'
          )

          entity = Case::Entity.represent(kase)

          expect(entity.custom_fields(kase)).to eq(
            custom_field_data.custom_field.title => 'Valor customizado'
          )
        end
      end

      context 'without report item' do
        it 'returns custom fields name' do
          kase = FactoryGirl.create :case
          custom_field = FactoryGirl.create :reports_custom_field
          entity = Case::Entity.represent(kase)

          expect(entity.custom_fields(kase)).to eq(custom_field.title => nil)
        end
      end
    end
  end
end
