class Inventory::ItemDataImage < Inventory::Base
  include EncodedImageUploadable

  belongs_to :item_data, class_name: 'Inventory::ItemData', foreign_key: 'inventory_item_data_id'

  mount_uploader :image, ImageUploader
  expose_multiple_versions :image

  def url
    image.url
  end

  class Entity < Grape::Entity
    expose :id
    expose :inventory_item_data_id
    expose :url
    expose :image_structure, as: :versions
  end
end
