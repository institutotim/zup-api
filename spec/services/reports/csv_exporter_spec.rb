require 'app_helper'

describe Reports::CSVExporter do
  let(:export) { build(:export) }

  subject { described_class.new(export) }

  describe '#to_csv' do
    context '#set_filters' do
      let(:user)      { create(:user) }
      let(:perimeter) { create(:reports_perimeter) }
      let(:category)  { create(:reports_category) }
      let(:status)    { create(:status) }

      let(:filters)   { subject.instance_variable_get('@filters') }

      it 'replace `users_ids` with users array' do
        export.filters = { users_ids: user.id.to_s }
        expect(filters[:user]).to eq([user])
      end

      it 'replace `reports_perimeters_ids` with perimeter array' do
        export.filters = { reports_perimeters_ids: perimeter.id.to_s }
        expect(filters[:perimeter]).to eq([perimeter])
      end

      it 'replace `reports_categories_ids` with category array' do
        export.filters = { reports_categories_ids: category.id.to_s }
        expect(filters[:category]).to eq([category])
      end

      it 'replace `reporters_ids` with user array' do
        export.filters = { reporters_ids: user.id.to_s }
        expect(filters[:reporter]).to eq([user])
      end

      it 'replace `statuses_ids` with status array' do
        export.filters = { statuses_ids: status.id.to_s }
        expect(filters[:statuses]).to eq([status])
      end
    end

    context '#records' do
      let(:search_engine) { Reports::SearchItems }

      it 'delegate the search to `Reports::SearchItems`' do
        expect(search_engine).to receive(:new).with(export.user, {}).and_call_original
        expect_any_instance_of(search_engine).to receive(:search).and_call_original

        subject.to_csv
      end
    end

    context 'header' do
      let(:headers) { subject.send('headers') }

      let(:expected_header) do
        ['Protocolo', 'Endereço', 'Referencia', 'Perimetro', 'Descrição', 'Categoria',
          'Data de Cadastro', 'Data de Atualização', 'Situação', 'Grupo Responsável',
          'Usuário Responsável', 'Nome do Solicitante', 'Email do Solicitante',
          'Telefone do Solicitante', 'Total de Comentários ao Solicitante',
          'Total de Observações Internas', 'Latitude', 'Longitude']
      end

      it 'include header in the csv' do
        csv = subject.to_csv
        expect(csv).to include(expected_header.to_csv)
      end
    end

    context 'content' do
      let!(:report) { create(:reports_item) }

      let(:expected_content) do
        [
          report.protocol,
          report.full_address,
          report.reference,
          report.perimeter.try(:title),
          report.description,
          report.category.try(:title),
          I18n.l(report.created_at, format: :long),
          I18n.l(report.updated_at, format: :long),
          report.status.try(:title),
          report.assigned_group.try(:name),
          report.assigned_user.try(:name),
          report.user.try(:name),
          report.user.try(:email),
          report.user.try(:phone),
          0,
          0,
          report.position.try(:y),
          report.position.try(:x)
        ]
      end

      it 'parse the report to csv' do
        csv = subject.to_csv
        expect(csv).to include(expected_content.to_csv)
      end
    end
  end
end
