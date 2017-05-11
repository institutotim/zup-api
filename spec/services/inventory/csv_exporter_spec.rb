require 'app_helper'

describe Inventory::CSVExporter do
  let(:category) { create(:inventory_category) }
  let(:export)   { build(:export, :inventory, inventory_category: category) }

  subject { described_class.new(export) }

  describe '#to_csv' do
    context '#set_filters' do
      let(:user)    { create(:user) }
      let(:status)  { create(:inventory_status) }
      let(:filters) { subject.instance_variable_get('@filters') }

      it 'use export category' do
        export.filters = { users_ids: user.id.to_s }
        expect(filters[:categories]).to eq([category])
      end

      it 'replace `inventory_statuses_ids` with statuses array' do
        export.filters = { inventory_statuses_ids: status.id.to_s }
        expect(filters[:statuses]).to eq([status])
      end

      it 'replace `users_ids` with users array' do
        export.filters = { users_ids: user.id.to_s }
        expect(filters[:users]).to eq([user])
      end
    end

    context '#records' do
      let(:search_engine) { Inventory::SearchItems }

      it 'delegate the search to `Inventory::SearchItems`' do
        expect(search_engine).to receive(:new).with(export.user, categories: [category]).and_call_original
        expect_any_instance_of(search_engine).to receive(:search).and_call_original

        subject.to_csv
      end
    end

    context 'parse inventories to CSV' do
      let(:section_one) { create(:inventory_section, category: category, position: 0, title: 'Person') }
      let(:section_two) { create(:inventory_section, category: category, position: 1, title: 'Address') }

      let!(:field_one)   { create(:inventory_field, section: section_one, position: 1, options: { label: 'Phone' }) }
      let!(:field_two)   { create(:inventory_field, section: section_one, position: 0, options: { label: 'Name' }) }
      let!(:field_three) { create(:inventory_field, section: section_two, position: 2, options: { label: 'Street' }) }

      let!(:field_four)  do
        create(
          :inventory_field,
          section: section_two,
          kind: 'checkbox',
          position: 3,
          options: { label: 'Options' }
        )
      end

      let!(:option_one) { create(:inventory_field_option, field: field_four, value: 'Option 1') }
      let!(:option_two) { create(:inventory_field_option, field: field_four, value: 'Option 2') }

      context 'header' do
        let(:headers) { subject.send('headers') }

        let(:expected_header) do
          [
            'Categoria', 'ID', 'Numero', 'Data de Cadastro', 'Data de Atualização',
            'Nome do Criador', 'Email do Criador', 'Nome do Atualizador',
             'Email do Atualizador', 'Situação', 'Person - Name', 'Person - Phone',
            'Address - Street', 'Address - Options', 'Localização - Latitude',
            'Localização - Longitude', 'Localização - Endereço', 'Localização - CEP',
            'Localização - Bairro', 'Localização - Cidade', 'Localização - Estado',
            'Localização - Codlog', 'Localização - Classificação Viária'
          ]
        end

        it 'include header in the csv' do
          csv = subject.to_csv
          expect(csv).to include(expected_header.to_csv)
        end
      end

      context 'content' do
        let!(:status) { create(:inventory_status, category: category) }

        let!(:inventory) do
          create(:inventory_item_without_data,
            category: category,
            status: status,
            sequence: 1
          )
        end

        let!(:history) { create(:inventory_history, :fields, item: inventory) }
        let(:updater)  { history.user }

        let(:expected_content) do
          [
            category.title,
            inventory.id,
            inventory.sequence,
            I18n.l(inventory.created_at, format: :long),
            I18n.l(inventory.updated_at, format: :long),
            inventory.user.name,
            inventory.user.email,
            updater.name,
            updater.email,
            status.title,
            'Name',
            'Phone',
            'Street',
            'Option 1; Option 2',
            'Latitude',
            'Longitude',
            'Endereço',
            'CEP',
            'Bairro',
            'Cidade',
            'Estado',
            'Codlog',
            'Classificação Viária'
          ]
        end

        before(:each) do
          category.fields.each do |field|
            if field.use_options?
              content = [option_one.id, option_two.id]
            end
            content ||= field.label

            item_data = inventory.data.create(field: field, content: content)
          end
        end

        it 'parse the inventory to csv' do
          csv = subject.to_csv
          expect(csv).to include(expected_content.to_csv)
        end
      end
    end

    context '#fields' do
      let(:category) { create(:inventory_category) }
      let(:section)  { create(:inventory_section, category: category) }

      let!(:active_field)             { create(:inventory_field, section: section) }
      let!(:inactive_field_with_data) { create(:inventory_field, section: section, disabled: true) }
      let!(:inactive_field)           { create(:inventory_field, section: section, disabled: true) }
      let!(:images_field)             { create(:inventory_field, section: section, kind: 'images') }
      let!(:attachments_field)        { create(:inventory_field, section: section, kind: 'attachments') }

      let!(:inventory) { create(:inventory_item_without_data, category: category) }
      let!(:data)      { create(:inventory_item_data, field: inactive_field_with_data, item: inventory) }

      it 'return only fields are active or have data and skip files' do
        fields_ids = subject.send('fields').map { |field| field.id }

        expect(fields_ids).to include(active_field.id)
        expect(fields_ids).to include(inactive_field_with_data.id)
        expect(fields_ids).to_not include(inactive_field.id)
        expect(fields_ids).to_not include(images_field.id)
        expect(fields_ids).to_not include(attachments_field.id)
      end
    end
  end
end
