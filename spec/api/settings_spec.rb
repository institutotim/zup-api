require 'app_helper'

describe Settings::API do
  let(:user) { create(:user) }

  describe 'GET /settings' do
    let!(:settings) do
      create_list(:setting, 2)
    end

    it 'returns all settings' do
      get '/settings', nil
      expect(parsed_body['settings']).to_not be_blank
    end
  end

  describe 'PUT /settings/:name' do
    let(:setting) do
      create(:setting)
    end

    let(:valid_params) do
      {
        value: [
          { id: nil, type: 'protocol', label: 'Protocolo' },
          { id: nil, type: 'address', label: 'Endereço' },
          { id: nil, type: 'user', label: 'Solicitante' },
          { id: nil, type: 'reporter', label: 'Criador' },
          { id: nil, type: 'category', label: 'Categoria' },
          { id: nil, type: 'assignment', label: 'Atribuído á' },
          { id: nil, type: 'created_at', label: 'Data de inclusão' }
        ]
      }
    end

    it 'updates the settings' do
      put "/settings/#{setting.name}", valid_params, auth(user)
      expect(response.status).to eq(200)
    end
  end
end
