require 'app_helper'

describe Reports::Perimeters::API do
  let(:group)     { create(:group) }
  let(:user)      { create(:user) }
  let(:perimeter) { create(:reports_perimeter) }

  context 'POST /reports/perimeters' do
    let(:valid_params) do
      {
        title: 'Perimeter',
        solver_group_id: group.id,
        priority: 20,
        shp_file: {
          file_name: 'shapefile.shp',
          content: Base64.encode64(fixture_file_upload("#{Application.config.root}/spec/fixtures/shapefiles/valid_shapefile.shp").read)
        },
        shx_file: {
          file_name: 'shapefile.shx',
          content: Base64.encode64(fixture_file_upload("#{Application.config.root}/spec/fixtures/shapefiles/valid_shapefile.shx").read)
        }
      }
    end

    subject do
      post '/reports/perimeters', valid_params, auth(user)
    end

    it 'create a new perimeter' do
      subject

      expect(response.status).to be_a_requisition_created

      perimeter = parsed_body['perimeter']

      expect(perimeter['id']).to_not be_nil
      expect(perimeter['title']).to eq(valid_params[:title])
      expect(perimeter['status']).to eq('pendent')
      expect(perimeter['group']).to_not be_nil
      expect(perimeter['namespace']['id']).to eq(user.namespace_id)
      expect(perimeter['active']).to be_truthy
      expect(perimeter['priority']).to eq(20)
    end
  end

  describe 'GET /reports/perimeters' do
    let!(:perimeters) do
      create_list(:reports_perimeter, 3)
    end

    subject do
      get '/reports/perimeters', nil, auth(user)
    end

    it 'return all perimeters' do
      subject

      expect(response.status).to be_a_success_request

      body = parsed_body['perimeters']

      expect(body.size).to eq(3)
      expect(body.map { |r| r['id'] }).to match_array(perimeters.map(&:id))
    end

    context 'search perimeters' do
      let!(:correct_perimeter) { create(:reports_perimeter, title: 'Report Perimeter') }

      it 'filter by perimeter title' do
        params = { title: 'report' }

        get '/reports/perimeters', params, auth(user)

        expect(response.status).to be_a_success_request

        body = parsed_body['perimeters']
        expect(body.size).to eq(1)
        expect(body.map { |r| r['id'] }).to match_array([correct_perimeter.id])
      end

      it 'sort perimeters' do
        params = { sort: 'created_at', order: 'desc' }

        get '/reports/perimeters', params, auth(user)

        expect(response.status).to be_a_success_request

        body = parsed_body['perimeters']

        perimeters_ids = perimeters.map { |r| r['id'] }
        perimeters_ids.push(correct_perimeter.id)

        expect(body.size).to eq(4)
        expect(body.map { |r| r['id'] }).to match_array(perimeters_ids.reverse)
      end

      it 'paginate perimeters' do
        params = { paginate: true, per_page: 2 }

        get '/reports/perimeters', params, auth(user)

        expect(response.status).to be_a_success_request

        body = parsed_body['perimeters']

        expect(body.size).to eq(2)
      end
    end
  end

  describe 'GET /reports/perimeters/:id' do
    subject do
      get "/reports/perimeters/#{perimeter.id}", nil, auth(user)
    end

    it 'returns the perimeter data' do
      subject

      expect(response.status).to be_a_success_request

      body = parsed_body['perimeter']

      expect(body['id']).to eq(perimeter.id)
      expect(body['title']).to eq(perimeter.title)
      expect(body['status']).to eq(perimeter.status)
    end
  end

  describe 'PUT /reports/perimeters/:id' do
    let(:valid_params) do
      {
        title: 'Perimeter',
        solver_group_id: group.id,
        active: false,
        priority: 50
      }
    end

    subject do
      put "/reports/perimeters/#{perimeter.id}", valid_params, auth(user)
    end

    it 'updates an existent perimeter' do
      subject

      expect(response.status).to be_a_success_request

      body = parsed_body['perimeter']

      expect(body['id']).to eq(perimeter.id)
      expect(body['title']).to eq(valid_params[:title])
      expect(body['status']).to eq(perimeter.status)
      expect(body['active']).to be_falsy
      expect(body['priority']).to eq(50)
      expect(body['group']['id']).to eq(group.id)
    end
  end

  describe 'PUT /reports/perimeters/:id/enable' do
    let(:perimeter) { create(:reports_perimeter, active: false) }

    subject do
      put "/reports/perimeters/#{perimeter.id}/enable", nil, auth(user)
    end

    it 'enable the perimeter' do
      subject

      expect(response.status).to be_a_success_request

      message = parsed_body['message']
      body = parsed_body['perimeter']

      expect(message).to eq('Perímetro ativado com sucesso')
      expect(body['id']).to eq(perimeter.id)
      expect(body['active']).to be_truthy
    end
  end

  describe 'DELETE /reports/perimeters/:id/disable' do
    let(:perimeter) { create(:reports_perimeter) }

    subject do
      delete "/reports/perimeters/#{perimeter.id}/disable", nil, auth(user)
    end

    it 'disable the perimeter' do
      subject

      expect(response.status).to be_a_success_request

      message = parsed_body['message']
      body = parsed_body['perimeter']

      expect(message).to eq('Perímetro desativado com sucesso')
      expect(body['id']).to eq(perimeter.id)
      expect(body['active']).to be_falsy
    end
  end

  describe 'DELETE /reports/perimeters/:id' do
    subject do
      delete "/reports/perimeters/#{perimeter.id}", nil, auth(user)
    end

    it 'removes an existent perimeter' do
      subject

      expect(response.status).to be_a_no_content_request
      expect(Reports::Perimeter.where(id: perimeter.id).first).to be_nil
    end
  end
end
