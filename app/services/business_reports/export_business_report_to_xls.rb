module BusinessReports
  class ExportBusinessReportToXls
    attr_reader :business_report

    def initialize(business_report)
      @business_report = business_report
    end

    def export
      require 'axlsx'

      package = Axlsx::Package.new
      wb = package.workbook

      business_report.charts.each do |chart|
        next unless chart.processed?

        wb.add_worksheet(name: trimmed_title(chart.title)) do |sheet|
          sheet.add_row(chart.data['subtitles'].keys)

          chart.data['content'].each do |row|
            sheet.add_row(row)
          end
        end
      end

      package
    end

    def trimmed_title(title)
      if title.size > 30
        "#{title[0..26]}..."
      else
        title
      end
    end
  end
end
