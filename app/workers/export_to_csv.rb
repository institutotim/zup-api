class ExportToCSV
  include Sidekiq::Worker

  def perform(export_id)
    if export = Export.find(export_id)
      service =
        if export.inventory?
          Inventory::CSVExporter.new(export)
        else
          Reports::CSVExporter.new(export)
        end

      tempfile = Tempfile.open('csv') do |tempfile|
        service.to_csv(output: tempfile)
      end

      export.update!(file: tempfile, status: :processed)
      tempfile.unlink
    end
  rescue => exception
    export.update!(status: :failed, file: nil)

    Raven.capture_exception(exception)
    raise exception
  end
end
