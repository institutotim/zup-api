module Reports
  class ScheduleWebhook
    attr_reader :report

    OBSERVED_FIELDS = %w(reports_status_id position address reference number
                         district postal_code city state country)

    def initialize(report)
      @report  = report
    end

    def schedule
      changes = report.previous_changes

      action =
        if changes['reports_category_id']
          old_category = Reports::Category.find(changes['reports_category_id'][0])

          action_by_category_change(old_category, report.category)
        elsif changes.keys.detect { |k| OBSERVED_FIELDS.include?(k) }
          'update'
        end

      SendReportThroughWebhook.perform_async(report.uuid, action) if action
    end

    def action_by_category_change(old_category, new_category)
      old_category_external = Webhook.external_category?(old_category)
      current_category_external = Webhook.external_category?(new_category)

      if old_category_external && !current_category_external
        'delete'
      elsif !old_category_external && current_category_external
        'insert'
      elsif old_category_external && current_category_external
        'update'
      end
    end
  end
end
