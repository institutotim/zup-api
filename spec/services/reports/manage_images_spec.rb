require 'spec_helper'

describe Reports::ManageImages do
  let(:user)  { create(:user) }
  let(:item)  { create(:reports_item) }
  let(:image) { create(:report_image, item: item) }

  let(:images_array) do
    [
      {
        title: 'Image 1',
        content: encoded_image('valid_report_item_photo.jpg'),
        origin: 'fiscal',
        visibility: 'internal'
      },
      { content: encoded_image('valid_report_item_photo.jpg') }
    ]
  end

  subject { described_class.new(user, item) }

  describe '#create!' do
    it 'create images' do
      subject.create!(images_array)
      expect(item.images.count).to eq(2)
    end

    it 'create images with title, origin and visibility' do
      images = subject.create!(images_array)

      image = images.first

      expect(image.id).to_not be_nil
      expect(image.title).to eq('Image 1')
      expect(image.origin).to eq('fiscal')
      expect(image.visibility).to eq('internal')
      expect(image.filename).to_not be_nil
    end

    it 'create images with only content' do
      images = subject.create!(images_array)
      image  = images.last

      expect(image.id).to_not be_nil
      expect(image.title).to be_nil
      expect(image.origin).to eq('citizen')
      expect(image.visibility).to eq('visible')
      expect(image.filename).to_not be_nil
    end

    it 'create histories entries' do
      subject.create!(images_array)

      item.histories.each do |history|
        expect(history.action).to match(/^Adicionada imagem: (.*).png/)
      end
    end

    context '#update!' do
      let(:images_array) do
        [
          {
            id: image.id,
            title: 'Image Updated',
            visibility: 'internal'
          }
        ]
      end

      it 'update image' do
        images = subject.update!(images_array)
        updated_image = images.first

        expect(updated_image.id).to eq(image.id)
        expect(updated_image.title).to eq('Image Updated')
        expect(updated_image.visibility).to eq('internal')
        expect(updated_image.url).to eq(image.url)
      end

      it 'create histories entries' do
        subject.update!(images_array)

        item.histories.each do |history|
          expect(history.action).to match(/^Atualizada imagem: (.*).png/)
        end
      end
    end
  end
end
