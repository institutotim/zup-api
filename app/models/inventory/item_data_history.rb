class Inventory::ItemDataHistory < Inventory::Base
  belongs_to :item_history, class_name: 'Inventory::ItemHistory',
                            foreign_key: 'inventory_item_history_id'
  belongs_to :item_data, class_name: 'Inventory::ItemData',
                         foreign_key: 'inventory_item_data_id'

  validates :item_history, :item_data, presence: true

  def previous_content=(content)
    if item_data.use_options?
      content = [content] unless content.is_a?(Array)
      self.previous_selected_options_ids = content.map(&:to_i)
    else
      super(content)
    end
  end

  def new_content=(content)
    if item_data.use_options?
      content = [content] unless content.is_a?(Array)
      self.new_selected_options_ids = content.map(&:to_i)
    else
      super(content)
    end
  end

  def previous_content
    if item_data.use_options?
      show_values_for_options(previous_selected_options_ids)
    else
      super
    end
  end

  def new_content
    if item_data.use_options?
      show_values_for_options(new_selected_options_ids)
    else
      super
    end
  end

  class Entity < Grape::Entity
    delegate :field, to: :item_data, allow_nil: false

    expose :field
    expose :previous_content
    expose :new_content

    def item_data
      object.item_data
    end
  end

  private

  def show_values_for_options(options_ids)
    values = Inventory::FieldOption.where(id: options_ids).map(&:value)

    if values.size == 1
      values.first
    else
      values
    end
  end
end
