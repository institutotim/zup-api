require 'app_helper'

describe Reports::DeleteThroughWebhook do
  let!(:report) { create(:reports_item) }

  subject { described_class.new(report.uuid) }

  before(:each) do
    Webhook.load_categories_from_file(
      File.join(Application.config.root, 'spec', 'support', 'webhook_categories.yml')
    )

    allow(Webhook).to receive(:url).and_return('http://api.external.com/')
    allow(Webhook).to receive(:update_url).and_return('http://api.external.com/process')
    allow(Webhook).to receive(:external_category_id).and_return('100')
    allow(Webhook).to receive(:report?).and_return(true)
    allow(Webhook).to receive(:solicitation?).and_return(false)

    allow(subject).to receive(:logger).and_return(double(:logger))
  end

  context '#delete!' do
    it 'success request' do
      stub_request(:delete, 'http://api.external.com/process')

      expect(subject.logger).to receive(:info)
        .with("Relato #{report.uuid} removido com sucesso!")

      subject.delete!
    end

    it 'error request' do
      stub_request(:delete, 'http://api.external.com/process').to_return(status: 404)

      expect(subject.logger).to receive(:error)
        .with("Ocorreu um erro ao remover o relato #{report.uuid} via integração:\n Requisição de envio retornou código de status: '404'")

      expect{ subject.delete! }.to raise_error("Requisição de envio retornou código de status: '404'")
    end
  end
end
