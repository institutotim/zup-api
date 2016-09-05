require 'app_helper'

describe Reports::UpdateItemFromWebhook do
  let!(:report) { create(:reports_item) }
  let!(:category) { report.category }
  let!(:other_category) do
    create(:reports_category_with_statuses, title: 'Solicitação/colocação de contêineres')
  end

  subject { described_class.new(report, valid_params) }

  before do
    Webhook.load_categories_from_file(
      File.join(Application.config.root, 'spec', 'support', 'webhook_categories.yml')
    )

    allow(subject).to receive(:external_category_id).and_return(100)
    allow(subject).to receive(:report?).and_return(true)
    allow(subject).to receive(:solicitation?).and_return(false)
    allow(Webhook).to receive(:enabled?).and_return(true)
  end

  context '#update!' do
    context 'changing status and adding comment' do
      let(:encoded_image) do
        Base64.encode64(fixture_file_upload('images/valid_report_item_photo.jpg').read).force_encoding(Encoding::UTF_8)
      end
      let(:valid_params) do
        {
          external_category_id: 100,
          status: {
            name: 'Resolvidas'
          },
          comments: [{
            user: {
              email: 'admin@zup.com.br',
              name: 'Administrador'
            },
            message: 'Este relato está finalizado'
          }]
        }
      end

      it 'updates the report item' do
        report = subject.update!
        report.reload

        expect(report.category).to eq(other_category)

        comment = report.comments.last
        expect(comment.message).to eq('Este relato está finalizado')
        expect(comment.author.email).to eq('admin@zup.com.br')

        status = report.status
        expect(status.title).to eq('Resolvidas')
      end
    end
  end
end
