class Inventory::FormulaHistory < Inventory::Base
  belongs_to :formula, class_name: 'Inventory::Formula', foreign_key: 'inventory_formula_id'
  belongs_to :item, class_name: 'Inventory::Item', foreign_key: 'inventory_item_id'
  belongs_to :alert, class_name: 'Inventory::FormulaAlert', foreign_key: 'inventory_formula_alert_id'

  validates :formula, presence: true
  validates :item, presence: true
end
