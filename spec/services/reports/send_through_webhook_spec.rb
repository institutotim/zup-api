require 'app_helper'

describe Reports::SendThroughWebhook do
  let!(:report) { create(:reports_item) }

  subject { described_class.new(report) }

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

  context '#insert!' do
    it 'success request' do
      stub_request(:post, 'http://api.external.com')

      expect(subject.logger).to receive(:info)
        .with("Relato ##{report.id} enviado com sucesso! Categoria: ##{report.category.id} (#{report.category.title})")

      subject.insert!
    end

    it 'error request' do
      stub_request(:post, 'http://api.external.com').to_return(status: 404)

      expect(subject.logger).to receive(:error)
        .with("Ocorreu um erro ao enviar o relato ##{report.id} via integração:\n Requisição de envio retornou código de status: '404'")

      expect{ subject.insert! }.to raise_error("Requisição de envio retornou código de status: '404'")
    end
  end

  context '#update!' do
    it 'success request' do
      stub_request(:put, 'http://api.external.com/process')

      expect(subject.logger).to receive(:info)
        .with("Relato ##{report.id} enviado com sucesso! Categoria: ##{report.category.id} (#{report.category.title})")

      subject.update!
    end

    it 'error request' do
      stub_request(:put, 'http://api.external.com/process').to_return(status: 404)

      expect(subject.logger).to receive(:error)
        .with("Ocorreu um erro ao enviar o relato ##{report.id} via integração:\n Requisição de envio retornou código de status: '404'")

      expect{ subject.update! }.to raise_error("Requisição de envio retornou código de status: '404'")
    end
  end
end
