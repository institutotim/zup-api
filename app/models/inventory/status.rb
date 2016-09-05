class Inventory::Status < Inventory::Base
  belongs_to :category, class_name: 'Inventory::Category', foreign_key: 'inventory_category_id'

  validates :title, presence: true, length: { maximum: 150 }
  validates :color, presence: true, css_hex_color: true

  class Entity < Grape::Entity
    expose :id
    expose :title
    expose :color

    expose :inventory_category, if: { collection: false }
    expose :inventory_category_id, if: { collection: true }

    expose :created_at
    expose :updated_at
  end
end
