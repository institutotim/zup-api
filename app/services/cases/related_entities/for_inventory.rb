module Cases
  class RelatedEntities
    class ForInventory
      attr_reader :inventory_item

      def initialize(inventory_item)
        @inventory_item = inventory_item
      end

      # An inventory item could be related to report items through:
      # - Foreign key `inventory_item_id` in report items table
      # - Related cases
      def fetch_report_items
        cases = fetch_cases
        report_items_ids = CaseStepDataField.joins(:case, :field)
                       .where('cases.id' => cases.map(&:id))
                       .where("fields.field_type = 'report_item'")
                       .map(&:value).map { |v| Oj.load(v)[0] }.uniq

        return [] if report_items_ids.blank?
        Reports::Item.where(id: report_items_ids)
      end

      # An inventory item could be related to another inventory items through related cases
      def fetch_inventory_items
        cases = fetch_cases
        inventory_item_ids = CaseStepDataField.joins(:case, :field)
                       .where('cases.id' => cases.map(&:id))
                       .where("fields.field_type = 'inventory_item'")
                       .where.not(value: "[#{inventory_item.id}]")
                       .map(&:value).map { |v| Oj.load(v)[0] }.uniq

        return [] if inventory_item_ids.blank?
        Inventory::Item.where(id: inventory_item_ids)
      end

      # An inventory item could be related to cases through inventory item selector fields
      def fetch_cases
        @fetched_cases ||= CaseStepDataField.joins(:field)
          .where("fields.field_type = 'inventory_item'")
          .where(value: "[#{inventory_item.id}]")
          .map(&:case).uniq
      end
    end
  end
end
