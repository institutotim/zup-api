module Cases
  class RelatedEntities
    class ForReport
      attr_reader :report

      def initialize(report)
        @report = report
      end

      # A report could be related to another report through related cases
      def fetch_report_items
        cases = fetch_cases
        report_ids = CaseStepDataField.joins(:case, :field)
          .where('cases.id' => cases.map(&:id))
          .where("fields.field_type = 'report_item'")
          .where.not(value: "[#{report.id}]")
          .map(&:value).map { |v| Oj.load(v)[0] }.uniq

        return [] if report_ids.blank?
        Reports::Item.where(id: report_ids)
      end

      # A report could be related to inventory items through:
      # - Foreign key `inventory_item_id`
      # - Related cases
      def fetch_inventory_items
        cases = fetch_cases
        inventory_items_ids = CaseStepDataField.joins(:case, :field)
                       .where('cases.id' => cases.map(&:id))
                       .where("fields.field_type = 'inventory_item'")
                       .map(&:value).map { |v| Oj.load(v)[0] }.uniq

        inventory_items_ids << report.inventory_item_id if report.inventory_item_id

        return [] if inventory_items_ids.blank?
        Inventory::Item.where(id: inventory_items_ids)
      end

      # A report could be related to cases through report selector fields
      def fetch_cases
        @fetched_cases ||= (CaseStepDataField.joins(:field)
          .where("fields.field_type = 'report_item'")
          .where(value: "[#{report.id}]")
          .map(&:case) + [Case.find_by(id: report.case_id)]).compact.uniq
      end
    end
  end
end
