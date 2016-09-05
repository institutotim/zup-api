require 'spec_helper'

describe Inventory::FieldOptions::API do
  let(:user) { create(:user) }
  let(:field) { create(:inventory_field) }

  let(:base_url) { "/inventory/fields/#{field.id}/options" }

  # Give permission for user to edit the field
  before do
    user.groups.first.permission.atomic_append(
      :inventory_fields_can_edit, field.id
    )
  end

  describe 'GET /inventory/fields/:field_id/options' do
    let!(:options) do
      create_list(:inventory_field_option, 2, field: field)
    end
    let!(:disabled_option) do
      create(:inventory_field_option, :disabled, field: field)
    end

    before do
      get base_url, nil, auth(user)
    end

    it 'returns only enabled options' do
      expect(response.status).to eq(200)
      expect(parsed_body['field_options'].map do |field|
        field['id']
      end).to match_array(options.map(&:id))
    end
  end

  describe 'POST /inventory/fields/:field_id/options' do
    let(:valid_params) do
      {
        value: 'Hey, choose me!'
      }
    end

    before do
      post base_url, valid_params, auth(user)
    end

    it 'creates the field option' do
      expect(response.status).to eq(201)
      expect(field.field_options.last.value).to eq(valid_params[:value])
    end

    context 'array as value' do
      let(:valid_params) do
        {
          value: ['Option 1', 'Option 2']
        }
      end

      it 'creates the field option' do
        expect(response.status).to eq(201)
        expect(field.field_options.map(&:value)).to match_array(['Option 1', 'Option 2'])
        expect(parsed_body['field_options']).to match(an_instance_of(Array))
      end
    end
  end

  context 'actions on specific field option' do
    let(:entity_url) do
      "#{base_url}/#{field_option.id}"
    end

    describe 'GET /inventory/fields/:field_id/options/:id' do
      let(:field_option) do
        create(:inventory_field_option, field: field)
      end

      before do
        get entity_url, nil, auth(user)
      end

      it 'returns the field option' do
        expect(response.status).to eq(200)
        expect(parsed_body['field_option']['id']).to eq(field_option.id)
      end
    end

    describe 'PUT /inventory/fields/:field_id/options/:id' do
      let(:field_option) do
        create(:inventory_field_option, field: field)
      end
      let(:valid_params) do
        {
          value: 'Hey, choose me!'
        }
      end

      before do
        put entity_url, valid_params, auth(user)
      end

      it 'creates the field option' do
        expect(response.status).to eq(200)
        expect(field_option.reload.value).to eq(valid_params[:value])
      end
    end

    describe 'DELETE /inventory/fields/:field_id/options/:id' do
      let(:field_option) do
        create(:inventory_field_option, field: field)
      end

      before do
        delete entity_url, nil, auth(user)
      end

      it 'disables the field' do
        expect(response.status).to eq(200)
        expect(field_option.reload.disabled?).to be_truthy
      end
    end
  end
end
