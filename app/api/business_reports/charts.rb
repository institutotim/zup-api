module BusinessReports
  module Charts
    class API < Base::API
      helpers do
        def load_chart(id = nil)
          Chart.find(id || params[:id])
        end

        def load_business_report(id = nil)
          BusinessReport.find(id || params[:business_report_id])
        end
      end

      namespace 'business_reports/:business_report_id/charts' do
        desc 'Get all charts for the metric report'
        get do
          authenticate!
          business_report = load_business_report
          validate_permission!(:view, business_report)

          present business_report.charts, using: Chart::Entity, only: return_fields
        end

        desc 'Get a specific chart for the metric report'
        get ':id' do
          authenticate!
          business_report = load_business_report
          chart = load_chart

          validate_permission!(:view, business_report)

          present chart, using: Chart::Entity, only: return_fields
        end

        desc 'Create a chart for the metric report'
        params do
          requires :metric, type: String
          requires :chart_type, type: String
          optional :title, type: String
          optional :description, type: String
          optional :categories_ids, type: Array[Integer]
          optional :begin_date, type: Date
          optional :end_date, type: Date
        end
        post do
          authenticate!
          business_report = load_business_report
          validate_permission!(:edit, business_report)

          chart_params = safe_params.permit(
            :metric, :chart_type, :title, :description,
            :begin_date, :end_date, categories_ids: []
          )

          chart = business_report.charts.create!(chart_params)
          FetchDataForChart.perform_async(chart.id)

          present chart, using: Chart::Entity, only: return_fields
        end

        desc 'Updates a chart for the metric report'
        params do
          optional :metric, type: String
          optional :chart_type, type: String
          optional :title, type: String
          optional :description, type: String
          optional :categories_ids, type: Array[Integer]
          optional :begin_date, type: Date
          optional :end_date, type: Date
        end
        put ':id' do
          authenticate!
          business_report = load_business_report
          chart = load_chart
          validate_permission!(:edit, business_report)

          chart_params = safe_params.permit(
            :metric, :chart_type, :title, :description,
            :begin_date, :end_date, categories_ids: []
          )

          chart.update!(chart_params)
          FetchDataForChart.perform_async(chart.id)

          present chart, using: Chart::Entity, only: return_fields
        end

        desc 'Deletes a chart from a metric report'
        delete ':id' do
          authenticate!
          business_report = load_business_report
          validate_permission!(:edit, business_report)

          load_chart.destroy!

          {
            message: I18n.t(:'charts.delete.success')
          }
        end
      end
    end
  end
end
