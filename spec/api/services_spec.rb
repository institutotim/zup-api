require 'app_helper'

describe Services::API do
  let(:user)    { create(:user) }
  let(:service) { create(:service) }

  context 'GET /services' do
    let!(:services) { create_list(:service, 3) }

    it 'list all services' do
      get '/services', nil, auth(user)

      expect(response.status).to be_a_success_request

      body = parsed_body['services']
      returned_ids = body.map { |b| b['id'] }
      services_ids = services.map { |s| s.id }

      expect(body.size).to eq(3)
      expect(returned_ids).to match_array(services_ids)
    end

    it 'filter service by name' do
      service = services.sample
      service.update!(name: 'Custom service')

      get '/services', { name: 'Custom' }, auth(user)

      expect(response.status).to be_a_success_request

      body = parsed_body['services']
      returned_ids = body.map { |b| b['id'] }

      expect(body.size).to eq(1)
      expect(returned_ids).to match([service.id])
    end

    it 'return disabled services' do
      disabled_service = create(:service, disabled: true)

      get '/services', { disabled: true }, auth(user)

      body = parsed_body['services']
      returned_ids = body.map { |b| b['id'] }

      expect(body.size).to eq(4)
      expect(returned_ids).to include(disabled_service.id)
    end
  end

  context 'GET /services/:id' do
    subject do
      get "/services/#{service.id}", nil, auth(user)
    end

    it 'show service info' do
      subject

      expect(response.status).to be_a_success_request

      body = parsed_body['service']

      expect(body['id']).to eq(service.id)
      expect(body['name']).to eq(service.name)
      expect(body['email']).to eq(service.email)
      expect(body['token']).to eq(service.token.key)
      expect(body['permissions']).to_not be_nil
    end
  end

  context 'POST /services' do
    let(:valid_params) do
      {
        name: 'Service One',
        email: 'service@mail.net'
      }
    end

    subject do
      post '/services', valid_params, auth(user)
    end

    it 'create a new service' do
      subject

      expect(response.status).to be_a_requisition_created

      body = parsed_body['service']

      expect(body['id']).to_not be_nil
      expect(body['name']).to eq(valid_params[:name])
    end
  end

  context 'PUT /services/:id' do
    let(:valid_params) do
      {
        name: 'Service Edited',
        email: 'service@mail.com'
      }
    end

    subject do
      put "/services/#{service.id}", valid_params, auth(user)
    end

    it 'update the service' do
      subject

      expect(response.status).to be_a_success_request

      body = parsed_body['service']

      expect(body['id']).to eq(service.id)
      expect(body['name']).to eq(valid_params[:name])
    end
  end

  context 'DELETE /services/:id' do
    it 'disable the service' do
      delete "/services/#{service.id}", nil, auth(user)

      expect(response.status).to be_a_success_request
      message = parsed_body['message']

      expect(message).to eq 'Serviço deletado com sucesso'
      expect(service.reload.disabled).to be_truthy
    end
  end

  context 'PUT /services/:id/enable' do
    it 'enable the service' do
      put "/services/#{service.id}/enable", nil, auth(user)

      expect(response.status).to be_a_success_request
      message = parsed_body['message']

      expect(message).to eq 'Serviço habilitado com sucesso'
      expect(service.reload.disabled).to be_falsy
    end
  end
end
