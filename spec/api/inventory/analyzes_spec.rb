require 'app_helper'

describe Inventory::Analyzes::API do
  let(:logged_user) { create(:user) }
  let(:category) { create(:inventory_category_with_sections) }
  let(:category_id) { category.id }

  describe 'GET /inventory/categories/:category_id/analyzes' do
    let!(:analyzes) { create_list(:inventory_analysis_with_scores, 3, category: category) }

    before { get "/inventory/categories/#{category_id}/analyzes", nil, auth(logged_user) }

    it { expect(response.status).to be_a_success_request }
    it { expect(parsed_body['analyzes'].count).to eq(3) }
    it { expect(parsed_body['analyzes']).to include_an_entity_of(analyzes.first) }
  end

  describe 'POST /inventory/categories/:category_id/analyzes' do
    let(:field) { category.fields.sample }
    let(:created_analysis) { category.analyzes.last }

    let(:create_params) do
      Oj.load <<-JSON
        {
          "title": "Fault tree",
          "expression": "$#{field.id} + 2",
          "scores": [{
            "inventory_field_id": #{field.id},
            "operator": "equal_to",
            "content": "test value",
            "score": 10
          }]
        }
      JSON
    end

    before { post "/inventory/categories/#{category_id}/analyzes", create_params, auth(logged_user) }

    context 'when all are right' do
      it { expect(response.status).to be_a_requisition_created }
      it { expect(parsed_body['analysis']).to be_an_entity_of(created_analysis) }
      it { expect(category.analyzes.count).to eq(1) }
      it { expect(created_analysis.scores.count).to eq(1) }
    end

    context 'when something is missing' do
      let(:create_params) { {} }

      it { expect(response.status).to be_a_bad_request }
    end

    context 'when the expression is invalid' do
      let(:create_params) do
        Oj.load <<-JSON
          {
            "title": "Invalid Analysis",
            "expression": "())+2+$a"
          }
        JSON
      end

      it { expect(response.status).to be_a_bad_request }
    end
  end

  describe 'PUT /inventory/categories/:category_id/analyzes/:id' do
    let(:field) { category.fields.sample }
    let(:analysis) { create(:inventory_analysis, category: category) }
    let(:score) { create(:inventory_analysis_score, analysis: analysis, score: 10) }

    let(:update_params) do
      Oj.load <<-JSON
        {
          "title": "Other title",
          "scores": [{
            "id": #{score.id},
            "operator": "different",
            "score": -10
          }]
        }
      JSON
    end

    before { put "/inventory/categories/#{category_id}/analyzes/#{analysis.id}", update_params, auth(logged_user) }

    context 'when all are right' do
      it { expect(response.status).to be_a_success_request }
      it { expect(parsed_body['analysis']).to be_an_entity_of(analysis.reload) }
      it { expect(analysis.reload.title).to eq(update_params['title']) }
      it { expect(score.reload.score).to eq(update_params['scores'][0]['score']) }
    end

    context 'when a score is removed' do
      let(:update_params) do
        Oj.load <<-JSON
          {
            "scores": [{
              "id": #{score.id},
              "_destroy": true
            }]
          }
        JSON
      end

      it { expect(response.status).to be_a_success_request }
      it { expect(parsed_body['analysis']['scores']).to_not include_an_entity_of(score) }
    end
  end

  describe 'DELETE /inventory/categories/:category_id/analyzes/:id' do
    let(:analysis) { create(:inventory_analysis, category: category) }

    before { delete "/inventory/categories/#{category_id}/analyzes/#{analysis.id}", nil, auth(logged_user) }

    it { expect(response.status).to be_a_success_request }
    it { expect(category.reload.analyzes).to_not include(analysis) }
  end
end
