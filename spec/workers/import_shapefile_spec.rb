require 'app_helper'

describe ImportShapefile do
  let(:perimeter) { create(:reports_perimeter) }

  subject { described_class.new.perform(perimeter.id) }

  describe '#perform' do
    context 'valid shapefile' do
      it 'succeffuly import to database' do
        subject

        expect(perimeter.reload.geometry).to_not be_nil
        expect(perimeter.reload.status).to eq('imported')
      end
    end

    context 'invalid quantity' do
      let(:perimeter) { create(:reports_perimeter, :invalid_quantity) }

      it 'do not import to database' do
        subject

        expect(perimeter.reload.geometry).to be_nil
        expect(perimeter.reload.status).to eq('invalid_quantity')
      end
    end

    context 'invalid geometry' do
      let(:perimeter) { create(:reports_perimeter, :invalid_geometry) }

      it 'do not import to database' do
        subject

        expect(perimeter.reload.geometry).to be_nil
        expect(perimeter.reload.status).to eq('invalid_file')
      end
    end

    context 'invalid file' do
      let(:perimeter) { create(:reports_perimeter, :invalid_file) }

      it 'do not import to database' do
        subject

        expect(perimeter.reload.geometry).to be_nil
        expect(perimeter.reload.status).to eq('invalid_quantity')
      end
    end

    context 'invalid srid' do
      let(:perimeter) { create(:reports_perimeter, :invalid_srid) }

      it 'do not import to database' do
        subject

        expect(perimeter.reload.geometry).to be_nil
        expect(perimeter.reload.status).to eq('invalid_quantity')
      end
    end
  end

  context 'when the report image is created' do
    it 'is scheduled a job for that' do
      expect do
        create(:reports_perimeter)
      end.to change(described_class.jobs, :size).by(1)
    end
  end
end
