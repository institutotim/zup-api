module Cases
  class RelatedEntities
    class ForCase
      attr_reader :kase

      def initialize(kase)
        @kase = kase
      end

      def fetch_cases
        []
      end

      # A case could be related to report items through:
      # - Fields containing report items linking
      def fetch_report_items
        report_items_ids = CaseStepDataField.joins(:case, :field)
                       .where('cases.id' => kase.id)
                       .where("fields.field_type = 'report_item'")
                       .map(&:value).map { |v| Oj.load(v)[0] }.uniq

        report_items_ids += Reports::Item.where(case_id: kase.id).pluck(:id)

        return [] if report_items_ids.blank?
        Reports::Item.where(id: report_items_ids)
      end

      # An inventory item could be related to another inventory items through related cases
      def fetch_inventory_items
        inventory_item_ids = CaseStepDataField.joins(:case, :field)
                       .where('cases.id' => kase.id)
                       .where("fields.field_type = 'inventory_item'")
                       .map(&:value).map { |v| Oj.load(v)[0] }.uniq

        return [] if inventory_item_ids.blank?
        Inventory::Item.where(id: inventory_item_ids)
      end
    end
  end
end
