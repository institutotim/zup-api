class Inventory::Formula < Inventory::Base
  belongs_to :category, class_name: 'Inventory::Category', foreign_key: 'inventory_category_id'
  belongs_to :status, class_name: 'Inventory::Status', foreign_key: 'inventory_status_id'

  has_many :conditions, class_name: 'Inventory::FormulaCondition', foreign_key: 'inventory_formula_id'
  has_many :histories, class_name: 'Inventory::FormulaHistory', foreign_key: 'inventory_formula_id'
  has_many :alerts, class_name: 'Inventory::FormulaAlert', foreign_key: 'inventory_formula_id'

  validates :status, presence: true
  validates :category, presence: true

  accepts_nested_attributes_for :conditions, allow_destroy: true

  class Entity < Grape::Entity
    expose :id

    with_options(unless: { collection: true }) do
      expose :status
      expose :category
    end

    with_options(if: { collection: true }) do
      expose :inventory_status_id
      expose :inventory_category_id
    end

    expose :conditions, using: Inventory::FormulaCondition::Entity

    expose :groups_to_alert
  end
end
