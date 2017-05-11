require 'app_helper'

describe ExportToCSV do
  let(:export_report) { create(:export) }
  let(:export_inventory) { create(:export, :inventory) }

  subject { described_class.new.perform(export_report.id) }

  describe '#perform' do
    context 'reports' do
      it 'change status to processed and save the file' do
        expect(Reports::CSVExporter).to receive(:new).with(export_report).and_call_original

        subject

        export_report.reload
        expect(export_report.status).to eq('processed')
        expect(export_report.file.blank?).to be_falsy
      end
    end

    context 'inventories' do
      subject { described_class.new.perform(export_inventory.id) }

      it 'change status to processed and save the file' do
        expect(Inventory::CSVExporter).to receive(:new).with(export_inventory).and_call_original

        subject

        export_inventory.reload
        expect(export_inventory.status).to eq('processed')
        expect(export_inventory.file.blank?).to be_falsy
      end
    end

    it 'change status to failed when any error happens' do
      allow(Reports::CSVExporter).to receive(:new).and_raise('error message')

      expect { subject }.to raise_error('error message')

      export_report.reload
      expect(export_report.status).to eq('failed')
      expect(export_report.file.blank?).to be_truthy
    end
  end
end
