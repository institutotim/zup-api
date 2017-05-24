require 'app_helper'

describe CSVExporter do
  let!(:access_key) { create_list(:access_key, 2) }
  let(:collection) { AccessKey.all }

  subject { CSVExporter.new(collection) }

  context 'parse collection to csv' do
    it 'include all column names and values' do
      csv = subject.to_csv

      expect(csv).to include("id,user_id,key,expired,expired_at,created_at,updated_at,expires_at,permanent\n")

      collection.pluck(:id, :user_id, :key, :expired, :expired_at, :created_at, :updated_at, :expires_at) do |c|
        expect(csv).to include(c.to_csv)
      end
    end

    it 'customize header and filter columns' do
      csv = subject.to_csv(headers: %w(user access_key), only: %w(user_id key))

      expect(csv).to include("user,access_key\n")

      collection.pluck(:user_id, :key) do |c|
        expect(csv).to include(c.to_csv)
      end
    end
  end

  context 'empty collection' do
    let(:collection) { AccessKey.none }

    it 'return only header when no data is found' do
      csv = subject.to_csv
      expect(csv).to eq("id,user_id,key,expired,expired_at,created_at,updated_at,expires_at,permanent\n")
    end
  end

  context 'errors' do
    let(:collection) { [] }

    it 'raise an error when invalid collection is passed' do
      expect { subject.to_csv }.to raise_error('You must provide a collection')
    end
  end

  context 'work with blocks' do
    it 'use passed block to fill csv' do
      csv = subject.to_csv do |file, collection|
        collection.each { |ak| file << [ak.id, ak.key] }
      end

      collection.pluck(:id, :key) do |c|
        expect(csv).to include(c.to_csv)
      end
    end
  end
end
