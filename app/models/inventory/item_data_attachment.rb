class Inventory::ItemDataAttachment < Inventory::Base
  mount_uploader :attachment, FilesUploader

  belongs_to :item_data, class_name: 'Inventory::ItemData', foreign_key: 'inventory_item_data_id'

  def url
    attachment.url
  end

  class Entity < Grape::Entity
    expose :url
  end
end
