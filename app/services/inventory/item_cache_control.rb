module Inventory
  class ItemCacheControl
    attr_reader :items

    def initialize(items)
      @items = items
    end

    def garner_cache_key
      #items.map(&:id).inject(:+)
      nil
    end
  end
end
