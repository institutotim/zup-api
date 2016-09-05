require 'app_helper'

describe Reports::Feedbacks::API do
  let(:user) { create(:user) }

  context 'GET /reports/:id/feedback' do
    let!(:report) { create(:reports_item) }
    let!(:feedback) do
      create(:reports_feedback, reports_item: report)
    end

    it 'returns feedbacks for the report' do
      get "/reports/#{report.id}/feedback", nil, auth(user)
      expect(response.status).to eq(200)
      body = parsed_body

      expect(body['feedback']['id']).to eq(feedback.id)
    end
  end

  context 'POST /reports/:id/feedback' do
    let(:report) { create(:reports_item) }
    let(:valid_params) do
        {
          'kind' => 'positive',
          'content' => 'Deu tudo certo',
          'images' => [
            Base64.encode64(fixture_file_upload("#{Application.config.root}/spec/fixtures/images/valid_report_item_photo.jpg").read),
            Base64.encode64(fixture_file_upload("#{Application.config.root}/spec/fixtures/images/valid_report_item_photo.jpg").read)
          ]
        }
    end

    it 'creates the feedback for the report' do
      Reports::UpdateItemStatus.new(report).update_status!(report.category.status_categories.final.first.status)

      post "/reports/#{report.id}/feedback", valid_params, auth(user)
      expect(response.status).to eq(201)
      body = parsed_body

      expect(body['feedback']).to_not be_nil
      expect(body['feedback']['kind']).to eq(valid_params['kind'])
      expect(body['feedback']['content']).to eq(valid_params['content'])
      expect(body['feedback']['images'].size).to eq(2)

      body['feedback']['images'].each do |image|
        expect(image['versions']['low']).to_not be_blank
        expect(image['versions']['high']).to_not be_blank
      end

      expect(report.reload.feedback).to_not be_nil
    end

    it "can't create if the report isn't on a final status" do
      expect(report.status.for_category(report.category, report.namespace_id).final?).to eq(false)

      post "/reports/#{report.id}/feedback", valid_params, auth(user)
      expect(response.status).to eq(401)
    end

    it "can't create if the user_response_time already is expired" do
      Reports::UpdateItemStatus.new(report).update_status!(report.category.status_categories.final.first.status)
      report.status_history
            .last
            .update!(
              created_at: \
                Time.now - report.category.user_response_time.seconds - 1.day
            )

      post "/reports/#{report.id}/feedback", valid_params, auth(user)
      expect(response.status).to eq(401)
    end
  end
end
