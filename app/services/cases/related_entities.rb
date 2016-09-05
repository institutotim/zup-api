module Cases
  class RelatedEntities
    attr_reader :subject, :instance

    def initialize(subject)
      @subject = subject

      klass_map = {
        Reports::Item => Cases::RelatedEntities::ForReport,
        Inventory::Item => Cases::RelatedEntities::ForInventory,
        Case => Cases::RelatedEntities::ForCase
      }

      fail "Class #{subject.class} is not mapped" unless klass_map.include?(subject.class)
      @instance = klass_map[subject.class].new(subject)
    end

    def report_items
      instance.fetch_report_items
    end

    def inventory_items
      instance.fetch_inventory_items
    end

    def cases
      instance.fetch_cases
    end

    class Entity < Grape::Entity
      expose :report_items, using: Reports::Item::Entity
      expose :inventory_items, using: Inventory::Item::Entity
      expose :cases, using: Case::Entity
    end
  end
end
