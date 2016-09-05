require 'app_helper'

describe ExtractDateFromImage do
  let!(:image) { create(:report_image) }

  subject { described_class.new.perform(image.id) }

  context 'when image have exif date' do
    let!(:image) { create(:report_image, :with_photo) }

    it '#perform' do
      expect(image.date).to be_nil

      subject

      expect(image.reload.date).to_not be_nil
      expect(image.reload.date.to_date).to eq '2015-10-14'.to_date
    end
  end

  context 'when image do not have exif date' do
    it '#perform' do
      expect(image.date).to be_nil
      subject
      expect(image.reload.date).to be_nil
    end
  end

  context 'when the report image is created' do
    it 'is scheduled a job for that' do
      image = create(:report_image, :with_photo)
      expect(described_class).to receive(:perform_async).with(image.id).and_return(true)
      image.run_callbacks(:commit)
    end
  end
end
