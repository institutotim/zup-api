require 'app_helper'

describe Reports::Images::API do
  let(:user)  { create(:user) }
  let!(:item) { create(:reports_item) }
  let(:image) { create(:report_image, item: item) }

  context 'GET /reports/items/:reports_item_id/images' do
    let!(:item) { create(:reports_item_with_images) }

    it 'list images' do
      get "/reports/items/#{item.id}/images/#", nil, auth(user)

      expect(response.status).to eq(200)

      images_ids = parsed_body['images'].map { |i| i['id'] }
      item_images_ids = item.images.map { |i| i.id }

      expect(images_ids).to eq(item_images_ids)
    end
  end

  context 'POST /reports/items/:reports_item_id/images' do
    let(:valid_params) do
      {
        images:[
          {
            content: encoded_image('valid_report_item_photo.jpg'),
            title: 'Image'
          }
        ]
      }
    end

    it 'create images' do
      post "/reports/items/#{item.id}/images/#", valid_params, auth(user)

      expect(response.status).to eq(201)

      image = parsed_body['images'].first

      expect(image['title']).to eq('Image')
      expect(image['original']).to_not be_nil
      expect(image['high']).to_not be_nil
      expect(image['low']).to_not be_nil
      expect(image['thumb']).to_not be_nil

      history = item.histories.first

      expect(history.action).to match(/^Adicionada imagem: (.*).png/)
    end
  end

  context 'PUT /reports/items/:reports_item_id/images' do
    let(:valid_params) do
      {
        images:[
          {
            id: image.id,
            title: 'New Image'
          }
        ]
      }
    end

    it 'update images' do
      put "/reports/items/#{item.id}/images/#", valid_params, auth(user)

      expect(response.status).to eq(200)

      body = parsed_body['images'].first

      expect(body['id']).to eq(image.id)
      expect(body['title']).to eq('New Image')
      expect(body['original']).to_not be_nil
      expect(body['high']).to_not be_nil
      expect(body['low']).to_not be_nil
      expect(body['thumb']).to_not be_nil
    end
  end

  context 'DELETE /reports/items/:reports_item_id/images/:id' do
    it 'removes a report image' do
      delete "/reports/items/#{item.id}/images/#{image.id}", nil, auth(user)

      expect(response.status).to eq(204)

      history = item.histories.last

      expect(history.action).to eq('Removida imagem: valid_report_category_icon.png')
      expect { image.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
