require 'spec_helper'

describe Reports::ItemHistories::API do
  let(:item) { create(:reports_item) }
  let(:user) { create(:user) }

  describe 'GET /reports/items/:id/history' do
    subject do
      get "/reports/items/#{item.id}/history", valid_params, auth(user)
    end

    context 'no params' do
      let!(:histories) { create_list(:reports_history, 5, :status, item: item) }
      let(:valid_params) { Hash.new }

      it 'returns everything' do
        subject
        expect(response.status).to eq(200)

        body = parsed_body
        expect(body['histories'].map do |h|
          h['id']
        end).to match_array(histories.map(&:id))
      end
    end

    context 'by date' do
      let!(:correct_histories) do
        create_list(:reports_history, 3, :status,
                    item: item, created_at: Date.new(2014, 1, 9))
      end
      let!(:wrong_histories) do
        create_list(:reports_history, 1, :status,
                    item: item, created_at: Date.new(2014, 1, 14))
      end
      let(:valid_params) do
        {
          created_at: {
            begin: Date.new(2014, 1, 9).iso8601,
            end:   Date.new(2014, 1, 13).iso8601
          }
        }
      end

      it 'returns the correct histories' do
        subject
        expect(response.status).to eq(200)

        body = parsed_body
        expect(body['histories'].map do |h|
          h['id']
        end).to match_array(correct_histories.map(&:id))
      end
    end

    context 'by user' do
      let(:other_user) { create(:user) }
      let!(:correct_histories) do
        create_list(:reports_history, 3, :status,
                    item: item, user: other_user)
      end
      let!(:wrong_histories) do
        create_list(:reports_history, 1, :status, item: item)
      end
      let(:valid_params) do
        {
          user_id: other_user.id
        }
      end

      it 'returns the correct histories' do
        subject
        expect(response.status).to eq(200)

        body = parsed_body
        expect(body['histories'].map do |h|
          h['id']
        end).to match_array(correct_histories.map(&:id))
      end
    end

    context 'by kind' do
      let!(:correct_histories) do
        create_list(:reports_history, 3, :status,
                    item: item)
      end
      let!(:wrong_histories) do
        create_list(:reports_history, 1, :category, item: item)
      end
      let(:valid_params) do
        {
          kind: 'status'
        }
      end

      it 'returns the correct histories' do
        subject
        expect(response.status).to eq(200)

        body = parsed_body
        expect(body['histories'].map do |h|
          h['id']
        end).to match_array(correct_histories.map(&:id))
      end
    end

    context 'by object' do
      let(:status) { create(:status) }
      let!(:correct_histories) do
        create_list(:reports_history, 3, :status,
                    item: item, objects_ids: [status.id])
      end
      let!(:wrong_histories) do
        create_list(:reports_history, 1, :status, item: item)
      end
      let(:valid_params) do
        {
          object_id: status.id
        }
      end

      it 'returns the correct histories' do
        subject
        expect(response.status).to eq(200)

        body = parsed_body
        expect(body['histories'].map do |h|
          h['id']
        end).to match_array(correct_histories.map(&:id))
      end
    end
  end
end
