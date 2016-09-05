require 'app_helper'

describe Webhook do
  let!(:webhook_category) { create(:reports_category, title: 'Solicitação/colocação de contêineres') }
  let(:category)          { create(:reports_category) }

  subject { described_class }

  before(:each) do
    Webhook.load_categories_from_file(
      File.join(Application.config.root, 'spec', 'support', 'webhook_categories.yml')
    )
  end

  describe '.find_category_by_title' do
    context 'passing an existent category' do
      context 'exactly' do
        let(:category_title) { 'Solicitação/colocação de contêineres' }

        it 'returns the correct object on the hash' do
          expect(subject.find_category_by_title(category_title)).to eq(['S', 100])
        end
      end

      context 'different case' do
        let(:category_title) { 'SOLICITAÇÃO/COLOCAÇÃO DE CONTÊINERES' }

        it 'returns the correct object on the hash' do
          expect(subject.find_category_by_title(category_title)).to eq(['S', 100])
        end
      end
    end
  end

  it '.enabled?' do
    allow(subject).to receive(:url).and_return('http://api.external.com/')
    allow(subject).to receive(:update_url).and_return('http://api.external.com/process')
    expect(subject.enabled?).to be_truthy
  end

  it '.external_category_id' do
    expect(subject.external_category_id(webhook_category)).to eq(100)
  end

  describe '.external_category?' do
    it { expect(subject.external_category?(webhook_category)).to be_truthy }
    it { expect(subject.external_category?(category)).to be_falsy }
  end

  it '.integration_categories' do
    expect(subject.integration_categories).to match([webhook_category])
  end

  it '.report?' do
    expect(subject.report?(webhook_category)).to be_falsy
  end

  it '.solicitation?' do
    expect(subject.solicitation?(webhook_category)).to be_truthy
  end

  it '.zup_category' do
    expect(subject.zup_category('100')).to eq(webhook_category)
  end
end
