require 'app_helper'

describe BusinessReports::API do
  let(:user) { create(:user) }
  let(:logged_user) { auth(user) }

  describe 'GET /business_reports' do
    let!(:business_reports) { create_list(:business_report, 3) }
    let(:request) { get '/business_reports', nil, logged_user }

    before { request }

    it { expect(response.status).to be_a_success_request }
    it { expect(parsed_body['business_reports'].count).to eq(3) }
    it { expect(parsed_body['business_reports'].map { |b| b['id'] }).to include(business_reports.first.id) }

    context 'when the user is not logged' do
      let(:request) { get '/business_reports', nil, auth(nil, user.namespace_id) }

      it { expect(response.status).to be_an_unauthorized }
    end

    describe 'pagination' do
      let(:params) { { page: 1, per_page: 2 } }
      let(:request) { get '/business_reports', params, logged_user }

      it { expect(response.status).to be_a_success_request }
      it { expect(parsed_body['business_reports'].count).to eq(params[:per_page]) }

      context 'when the page is out of range' do
        let(:params) { { page: 10, per_page: 2 } }

        it { expect(response.status).to be_a_success_request }
        it { expect(parsed_body['business_reports'].count).to eq(0) }
      end
    end
  end

  describe 'POST /business_reports' do
    let(:created_business_report) { BusinessReport.last }
    let(:create_params) do
      {
          title: 'Titulo #1',
          summary: 'Summary #1',
          params: { my: { arbitrarily: { complex: ['object'] } } }
      }
    end
    let(:request) { post '/business_reports', create_params.as_json, logged_user }

    before { request }

    context 'when the user is not logged' do
      let(:request) { post '/business_reports', create_params.as_json, auth(nil, user.namespace_id) }

      it { expect(response.status).to be_an_unauthorized }
    end

    context 'when everything is right' do
      it { expect(response.status).to be_a_requisition_created }
      it { expect(parsed_body['business_report']).to be_an_entity_of(created_business_report) }
    end
  end

  describe 'PUT /business_reports/:id' do
    let(:business_report) { create(:business_report) }
    let(:business_report_id) { business_report.id }
    let(:update_params) do
      {
          title: 'Titulo #2',
          summary: 'Summary #2',
          params: { my: { arbitrarily: { complex: ['object'] } } }
      }
    end
    let(:request) { put "/business_reports/#{business_report_id}", update_params, logged_user }

    before { request }

    context 'when the user is not logged' do
      let(:request) { put "/business_reports/#{business_report_id}", update_params, auth(nil, user.namespace_id) }

      it { expect(response.status).to be_an_unauthorized }
    end

    context 'when the business report does not exists' do
      let(:business_report_id) { 'unknown' }

      it { expect(response.status).to be_a_not_found }
    end

    context 'when everything is right' do
      it { expect(response.status).to be_a_success_request }
      it { expect(parsed_body['business_report']).to be_an_entity_of(business_report.reload) }
    end
  end

  describe 'DELETE /business_reports/:id' do
    let(:business_report) { create(:business_report) }
    let(:business_report_id) { business_report.id }
    let(:request) { delete "/business_reports/#{business_report_id}", nil, logged_user }

    before { request }

    context 'when the user is not logged' do
      let(:request) { put "/business_reports/#{business_report_id}", nil, auth(nil, user.namespace_id) }

      it { expect(response.status).to be_an_unauthorized }
    end

    context 'when the view does not exists' do
      let(:business_report_id) { 'unknown' }

      it { expect(response.status).to be_a_not_found }
    end

    context 'when everything is right' do
      it { expect(response.status).to be_a_success_request }
    end
  end
end
