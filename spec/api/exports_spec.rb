require 'spec_helper'

describe Exports::API do
  let(:user)     { create(:user) }
  let(:export)   { create(:export, user: user) }
  let(:category) { create(:inventory_category) }

  context 'POST /exports' do
    let(:valid_params) do
      {
        kind: 'inventory',
        inventory_category_id: category.id,
        filters: { users_ids: '1,2,3' }
      }
    end

    subject do
      post 'exports', valid_params, auth(user)
    end

    it 'create a new export for inventories' do
      expect(ExportToCSV).to receive(:perform_async)

      subject

      expect(response.status).to be_a_requisition_created

      body = parsed_body['export']

      expect(body['id']).to_not be_nil
      expect(body['status']).to eq('pendent')
      expect(body['kind']).to eq('inventory')
      expect(body['url']).to be_nil
      expect(body['created_at']).to_not be_nil
      expect(body['category']).to_not be_nil

      export = Export.last

      expect(export).to_not be_nil
      expect(export.inventory_category_id).to eq(category.id)
      expect(export.filters).to eq('users_ids' => '1,2,3')
    end

    it 'create a new export for reports' do
      post 'exports', { kind: 'report' }, auth(user)

      expect(response.status).to be_a_requisition_created

      body = parsed_body['export']

      expect(body['id']).to_not be_nil
      expect(body['status']).to eq('pendent')
      expect(body['kind']).to eq('report')
      expect(body['url']).to be_nil
      expect(body['created_at']).to_not be_nil
    end
  end

  describe 'GET /exports' do
    let!(:exports) do
      create_list(:export, 3, user: user)
    end

    subject do
      get '/exports', nil, auth(user)
    end

    it 'return all exports' do
      subject

      expect(response.status).to be_a_success_request

      body = parsed_body['exports']

      expect(body.size).to eq(3)
      expect(body.map { |r| r['id'] }).to match_array(exports.map(&:id))
    end

    it 'paginate exports' do
      get '/exports', { per_page: 1 }, auth(user)

      expect(response.status).to be_a_success_request

      body = parsed_body['exports']

      expect(body.size).to eq(1)
    end

    it 'sort exports' do
      get '/exports', { sort: 'created_at', order: 'asc' }, auth(user)

      expect(response.status).to be_a_success_request

      body = parsed_body['exports']

      returned_ids = body.map { |e| e['id'] }
      expected_ids = exports.sort_by { |e| e.created_at }.map { |e| e.id }

      expect(returned_ids).to eq(expected_ids)
    end
  end

  describe 'DELETE /exports/:id' do
    subject do
      delete "/exports/#{export.id}", nil, auth(user)
    end

    it 'removes an existent export' do
      subject

      expect(response.status).to be_a_no_content_request
      expect(Export.find_by(id: export.id)).to be_nil
    end
  end
end
