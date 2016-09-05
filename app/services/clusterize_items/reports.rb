module ClusterizeItems
  class Reports < ClusterizeItems::Base
    def initialize(*args)
      args += [{
                 klass: ::Reports::Item,
                 category_attribute: :reports_category_id,
                 item_type: :reports
               }]
      super(*args)
    end
  end
end
