require 'spec_helper'

describe Inventory::CreateItemFromCategoryForm do
  let!(:namespace) { create(:namespace) }
  let!(:category)  { create(:inventory_category_with_sections) }
  let!(:user)      { create(:user) }

  context 'item creation' do
    context 'valid params' do
      let(:item_params) do
        fields = category.fields
        item_params = {}

        fields.each do |field|
          item_params[field.id] = 'Rua do Banco'
        end

        item_params
      end

      it 'creates the item' do
        described_class.new(
          category: category,
          user: user,
          data: item_params,
          namespace_id: namespace.id
        ).create!

        item = category.reload.items.first

        expect(item.namespace_id).to eq(namespace.id)
        expect(item.data.joins(:field).where(inventory_fields: { kind: 'text' }).first.content).to eq('Rua do Banco')
        expect(item.data.size).to eq(category.fields.size)
      end

      context 'with image field' do
        let!(:images_field_id) do
          category.sections.last.fields.create(
            title: 'Imagens',
            kind: 'images',
            position: 0
          ).id
        end
        let!(:item_params) do
          fields = category.fields
          item_params = {}

          fields.each do |field|
            unless field.kind == 'images'
              item_params[field.id] = 'Rua do Banco'
            else
              item_params[field.id] = [
                {
                  'content' => Base64.encode64(fixture_file_upload("#{Application.config.root}/spec/fixtures/images/valid_report_item_photo.jpg").read)
                },
                {
                  'content' => Base64.encode64(fixture_file_upload("#{Application.config.root}/spec/fixtures/images/valid_report_item_photo.jpg").read)
                }
              ]
            end
          end

          item_params
        end

        it "create item with images if field is the 'images' type" do
          data = described_class.new(
            category: category,
            user: user,
            data: item_params,
            namespace_id: namespace.id
          ).create!

          item = category.reload.items.first
          item_data = item.data.find_by(inventory_field_id: images_field_id)

          expect(item_data.content.class).to eq(Array)
          expect(item_data.content).to_not be_empty
        end
      end
    end

    context 'with invalid params' do
      context 'required fields missing' do
        let(:item_params) do
          fields = category.fields
          item_params = {}

          fields.each do |field|
            unless field.required?
              item_params[field.id] = 'Rua do Banco'
            end
          end

          user.groups.first.permission.update!(inventory_fields_can_edit: [field.id])

          item_params
        end

        subject do
          described_class.new(
            category: category,
            user: user,
            data: item_params,
            namespace_id: namespace.id
          )
        end

        it 'creates the item' do
          expect { subject.create! }.to raise_error
        end
      end
    end
  end
end
