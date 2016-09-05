class FetchDataForChart
  include Sidekiq::Worker

  def perform(chart_id)
    chart = Chart.find_by(id: chart_id)

    if chart
      BusinessReports::CompileDataForChart.new(chart).compile!
    end
  end
end
