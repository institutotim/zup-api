class CSVExporter
  attr_reader :collection, :output, :headers, :columns

  def initialize(collection)
    @collection = collection
  end

  def to_csv(options = {}, &block)
    fail 'You must provide a collection' unless collection.is_a?(ActiveRecord::Relation)

    @columns = Array(options.fetch(:only) { collection.column_names })
    @headers = options.fetch(:headers) { columns }
    @output  = options.fetch(:output) { '' }

    generate_csv(&block)
  end

  private

  def generate_csv
    CSV(output) do |csv|
      csv << headers if headers

      if block_given?
        yield csv, collection
      else
        collection.find_in_batches do |records|
          records.each do |record|
            csv << columns.map { |column| record.public_send(column) }
          end
        end
      end
    end

    output
  end
end
