require 'app_helper'

describe Reports::Webhooks::API do
  let!(:category) { create(:reports_category_with_statuses, title: 'Solicitação/colocação de contêineres') }
  let!(:report)   { create(:reports_item) }

  before do
    Webhook.load_categories_from_file(
      File.join(Application.config.root, 'spec', 'support', 'webhook_categories.yml')
    )
  end

  context 'POST /reports/webhooks' do
    let(:encoded_image) do
      Base64.encode64(fixture_file_upload("#{Application.config.root}/spec/fixtures/images/valid_report_item_photo.jpg").read).force_encoding(Encoding::UTF_8)
    end
    let(:valid_params) do
      {
        external_category_id: 100,
        is_report: true,
        is_solicitation: false,
        namespace_id: report.namespace_id,
        latitude: -13.12427698396538,
        longitude: -21.385812899349485,
        description: 'Este é um relato de exemplo',
        address: 'Av. Paulista, 130',
        reference: 'Próximo à Gazeta',
        images: [
          { 'mime-type' => 'image/png', data: encoded_image }
        ],
        status: {
          name: 'Em andamento'
        },
        user: {
          email: 'usuario@zup.com.br',
          name: 'Usuário de Teste'
        },
        comments: [{
          user: {
            email: 'admin@zup.com.br',
            name: 'Administrador'
          },
          message: 'Este é um comentário'
        }]
      }
    end

    it 'should import a report item' do
      post '/reports/webhooks', valid_params

      expect(response.status).to eq(201)
      body = parsed_body

      expect(body['message']).to eq('Relato criado com sucesso')
      expect(body['uuid']).to_not be_nil
    end
  end

  context 'PUT /reports/webhooks/:uuid' do
    let(:valid_params) do
      {
        status: {
          name: 'Aguardando liberação'
        },
        comments: [{
          user: {
            email: 'admin@zup.com.br',
            name: 'Administrador'
          },
          message: 'Este é um novo comentário'
        }]
      }
    end

    it 'should update a report item' do
      put "/reports/webhooks/#{report.uuid}", valid_params

      expect(response.status).to eq(200)
      expect(parsed_body['message']).to eq('Relato atualizado com sucesso')
    end
  end

  context 'DELETE /reports/webhooks/:uuid' do
    it 'should delete a report item' do
      delete "/reports/webhooks/#{report.uuid}"

      expect(response.status).to eq(200)
      expect(parsed_body['message']).to eq('Relato deletado com sucesso')
    end
  end
end
