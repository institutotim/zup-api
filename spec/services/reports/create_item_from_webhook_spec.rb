require 'app_helper'

describe Reports::CreateItemFromWebhook do
  let!(:category)  { create(:reports_category_with_statuses, title: 'Solicitação/colocação de contêineres') }
  let!(:namespace) { create(:namespace) }

  before do
    Webhook.load_categories_from_file(
      File.join(Application.config.root, 'spec', 'support', 'webhook_categories.yml')
    )

    allow(subject).to receive(:external_category_id).and_return(100)
    allow(subject).to receive(:report?).and_return(true)
    allow(subject).to receive(:solicitation?).and_return(false)
    allow(Webhook).to receive(:enabled?).and_return(true)
  end

  subject { described_class.new(valid_params) }

  context '#create!' do
    let(:encoded_image) do
      Base64.encode64(fixture_file_upload("#{Application.config.root}/spec/fixtures/images/valid_report_item_photo.jpg").read).force_encoding(Encoding::UTF_8)
    end
    let(:valid_params) do
      {
        external_category_id: 100,
        namespace_id: namespace.id,
        is_report: true,
        is_solicitation: false,
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

    it 'creates the report item' do
      report = subject.create!

      expect(report.external_category_id).to eq(100)
      expect(report.is_solicitation).to be_falsy
      expect(report.is_report).to be_truthy
      expect(report.namespace_id).to eq(namespace.id)
      expect(report.position.y).to eq(-13.12427698396538)
      expect(report.position.x).to eq(-21.385812899349485)
      expect(report.category).to eq(category)
      expect(report.from_webhook).to be_truthy

      comment = report.comments.last
      expect(comment.message).to eq('Este é um comentário')
      expect(comment.author.email).to eq('admin@zup.com.br')
      expect(comment.from_webhook).to be_truthy

      image = report.images.last
      expect(image).to_not be_nil

      status = report.status
      expect(status.title).to eq('Em andamento')

      user = report.user
      expect(user.email).to eq('usuario@zup.com.br')
      expect(user.name).to eq('Usuário de Teste')
      expect(user.from_webhook).to be_truthy
    end
  end
end
