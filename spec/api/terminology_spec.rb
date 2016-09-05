require 'app_helper'

describe Terminology::API do
  subject { get '/terminology' }

  context 'without custom terminology' do
    before do
      I18n.load_path = Dir[File.join(Application.config.root, 'config', 'locales', '*.yml')]
      I18n.backend.reload!
    end

    it 'returns the default terminology' do
      subject
      expect(response.status).to be_a_success_request
      expect(parsed_body).to include(
                               'INVENTORY' => 'Inventário',
                               'INVENTORIES' => 'Inventários',
                               'REPORT' => 'Relato',
                               'REPORTS' => 'Relatos',
                               'REPORTS_FILTERS_WITH_CATEGORIES' => 'Com as categorias...'
                             )
    end
  end

  context 'with custom terminology' do
    before do
      I18n.load_path = Dir[File.join(Application.config.root, 'spec', 'support', 'custom_terminology.yml')]
      I18n.load_path += Dir[File.join(Application.config.root, 'config', 'locales', '*.yml')]
      I18n.backend.reload!
      I18n.backend.load_translations
    end

    it 'returns the custom terminology' do
      subject
      expect(response.status).to be_a_success_request
      expect(parsed_body).to include(
                               'INVENTORY' => 'Teste',
                               'INVENTORIES' => 'Inventários',
                               'REPORT' => 'Relato',
                               'REPORTS' => 'Relatos',
                               'REPORTS_FILTERS_WITH_CATEGORIES' => 'Com as categorias...'
                             )
    end
  end
end
