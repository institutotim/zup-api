module ClusterizeItems
  class Inventory < ClusterizeItems::Base
    def initialize(*args)
      args += [{
                 klass: ::Inventory::Item,
                 category_attribute: :inventory_category_id,
                 item_type: :items
               }]
      super(*args)
    end
  end
end
