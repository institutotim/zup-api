module BusinessReports
  class CompileDataForChart
    attr_reader :chart, :metric_class

    def initialize(chart, metric_class = nil)
      @chart = chart
      @metric_class = metric_class || guess_metric_class
    end

    def compile!
      unless metric_class
        fail "You need a valid metric class for metric '#{chart.metric}'"
      end

      chart_params = {
        categories_ids: chart.categories_ids
      }

      # Use the metric class to compile data
      chart_data = metric_class.new(
        chart.begin_date.beginning_of_day..chart.end_date.end_of_day, chart_params
      ).fetch_data

      chart_data = adapt_to_chart_type(chart_data)

      if chart_data
        chart.update!(data: chart_data.serialize)
      end
    end

    def guess_metric_class
      klass = chart.metric.to_s.gsub('-', '_').camelize
      "BusinessReports::Metrics::#{klass}".constantize
    end

    private

    def adapt_to_chart_type(chart_data)
      # TODO: Here we will put the data in the right format for the chart.
      chart_data
    end
  end
end
