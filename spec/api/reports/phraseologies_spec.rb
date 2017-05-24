require 'app_helper'

describe Reports::Phraseologies::API do
  let(:user)        { create(:user) }
  let(:category)    { create(:reports_category) }
  let(:phraseology) { create(:reports_phraseology) }

  context 'POST /reports/phraseologies' do
    let(:valid_params) do
      {
        title: 'Title',
        description: 'Description',
        reports_category_id: category.id
      }
    end

    subject do
      post '/reports/phraseologies', valid_params, auth(user)
    end

    it 'create a new phraseology' do
      subject

      expect(response.status).to be_a_requisition_created

      body = parsed_body['phraseology']

      expect(body['id']).to_not be_nil
      expect(body['title']).to eq('Title')
      expect(body['description']).to eq('Description')
      expect(body['category']).to_not be_nil
      expect(body['category']['id']).to eq(category.id)
      expect(body['category']['title']).to eq(category.title)
    end
  end

  describe 'GET /reports/phraseologies' do
    context 'listing phraseologies' do
      let!(:phraseologies) do
        create_list(:reports_phraseology, 3, category: category)
      end

      it 'return all phraseologies' do
        get '/reports/phraseologies', { grouped: false }, auth(user)

        expect(response.status).to be_a_success_request

        body = parsed_body['phraseologies']

        expect(body.size).to eq(3)
        expect(body.map { |r| r['id'] }).to match_array(phraseologies.map(&:id))
      end

      it 'return phraseologies grouped' do
        get '/reports/phraseologies', nil, auth(user)

        expect(response.status).to be_a_success_request

        body = parsed_body['phraseologies']

        expect(body[category.title]).to_not be_nil

        phraseologies_ids =  body[category.title].map { |p| p['id'] }

        expect(body.size).to eq(1)
        expect(phraseologies_ids).to match(phraseologies.map { |p| p.id })
      end
    end

    context 'filter phraseologies' do
      let!(:phraseology)         { create(:reports_phraseology, category: category) }
      let!(:public_phraseology)  { create(:reports_phraseology, category: category) }
      let!(:another_phraseology) { create(:reports_phraseology, :with_category) }

      let(:valid_params) do
        {
          reports_category_id: category.id,
          grouped: false
        }
      end

      it 'by category' do
        get '/reports/phraseologies', valid_params, auth(user)

        expect(response.status).to be_a_success_request

        body = parsed_body['phraseologies']
        phraseologies_ids =  body.map { |p| p['id'] }

        expect(body.size).to eq(2)
        expect(phraseologies_ids).to match([phraseology.id, public_phraseology.id])
      end
    end
  end

  describe 'GET /reports/phraseologies/:id' do
    let(:phraseology) { create(:reports_phraseology, category: category) }

    it 'return phraseology data' do
      get "/reports/phraseologies/#{phraseology.id}", nil, auth(user)

      expect(response.status).to be_a_success_request

      body = parsed_body['phraseology']

      expect(body['id']).to eq(phraseology.id)
      expect(body['title']).to eq(phraseology.title)
      expect(body['description']).to eq(phraseology.description)
      expect(body['category']).to_not be_nil
      expect(body['category']['id']).to eq(category.id)
      expect(body['category']['title']).to eq(category.title)
    end
  end

  describe 'PUT /reports/phraseologies/:id' do
    let(:valid_params) do
      {
        title: 'New Title',
        description: 'New Description',
        reports_category_id: category.id
      }
    end

    subject do
      put "/reports/phraseologies/#{phraseology.id}", valid_params, auth(user)
    end

    it 'updates an existent phraseology' do
      subject

      expect(response.status).to be_a_success_request

      body = parsed_body['phraseology']

      expect(body['id']).to_not be_nil
      expect(body['title']).to eq('New Title')
      expect(body['description']).to eq('New Description')
      expect(body['category']).to_not be_nil
      expect(body['category']['id']).to eq(category.id)
      expect(body['category']['title']).to eq(category.title)
    end
  end

  describe 'DELETE /reports/phraseologies/:id' do
    subject do
      delete "/reports/phraseologies/#{phraseology.id}", nil, auth(user)
    end

    it 'removes an existent phraseology' do
      subject

      expect(response.status).to be_a_no_content_request
      expect(Reports::Phraseology.find_by(id: phraseology.id)).to be_nil
    end
  end
end
