class Inventory::FieldOption < Inventory::Base
  belongs_to :field, class_name: 'Inventory::Field',
                     foreign_key: 'inventory_field_id'

  validates :value, presence: true, uniqueness: { scope: :inventory_field_id }

  scope :enabled, -> {
    where(inventory_field_options: { disabled: false })
  }

  scope :sorted, -> {
    order(value: :asc)
  }

  # Disable this field option
  def disable!
    update!(disabled: true)
  end

  class Entity < Grape::Entity
    expose :id
    expose :inventory_field_id
    expose :disabled
    expose :value
  end
end
