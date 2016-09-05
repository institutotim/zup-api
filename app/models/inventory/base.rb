class Inventory::Base < ActiveRecord::Base
  self.abstract_class = true
  self.table_name_prefix = 'inventory_'

  class << self
    def rgeo_factory
      RGeo::Geographic.simple_mercator_factory
    end
  end
end
