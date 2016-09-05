require 'spec_helper'

describe Reports::CustomFields::API do
  let(:user) { create(:user) }

  describe 'GET :id/custom_fields' do
    let(:custom_fields) { create_list(:reports_custom_field, 3) }

    subject { get '/reports/custom_fields', nil, auth(user) }

    it 'returns all custom fields' do
      custom_fields

      subject

      expect(response.status).to eq(200)
      returned_custom_fields = parsed_body['custom_fields']
      expect(returned_custom_fields.map { |c| c['id'] }).to match_array(custom_fields.map(&:id))
    end

    context 'searching by title' do
      let(:custom_fields) do
        [
          create(:reports_custom_field, title: 'Tive'),
          create(:reports_custom_field, title: 'tiveoly')
        ]
      end

      let(:wrong_custom_fields) do
        [
          create(:reports_custom_field, title: 'Test'),
          create(:reports_custom_field, title: 'Nope test')
        ]
      end

      subject { get '/reports/custom_fields?title=tive', nil, auth(user) }

      it 'returns only custom fields satisfying the search' do
        custom_fields
        wrong_custom_fields

        subject

        expect(response.status).to eq(200)
        returned_custom_fields = parsed_body['custom_fields']
        expect(returned_custom_fields.map { |c| c['id'] }).to match_array(custom_fields.map(&:id))
        expect(returned_custom_fields.map { |c| c['id'] }).to_not match_array(wrong_custom_fields.map(&:id))
      end
    end
  end
end
