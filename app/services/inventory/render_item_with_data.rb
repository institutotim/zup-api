class Inventory::RenderItemWithData
  attr_reader :item

  def initialize(item)
    @item = item
  end

  def render
    item_hash = {}
    item_hash['id'] = item.id
    item_hash['data'] = []

    item.data.each do |data|
      item_hash['data'] << {
        'field' => data.field.as_json,
        'content' => data.content
      }
    end

    item_hash
  end
end
