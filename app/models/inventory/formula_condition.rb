class Inventory::FormulaCondition < Inventory::Base
  OPERATORS = %w(
    equal_to
    greater_than
    lesser_than
    different
    between
    includes
  )

  belongs_to :formula, class_name: 'Inventory::Formula', foreign_key: 'inventory_formula_id'
  belongs_to :conditionable, polymorphic: true

  validates :operator, presence: true, inclusion: { in: OPERATORS }
  validates :conditionable, presence: true

  # Override the setter to allow
  # accepting images and string values
  def content=(content)
    if !content.is_a?(Array)
      write_attribute(:content, [content])
    else
      super
    end
  end

  def content
    if !super.nil? && conditionable.try(:use_options?)
      super.map(&:to_i)
    elsif !super.nil? && super.size == 1
      super.first
    else
      super
    end
  end

  class Entity < Grape::Entity
    expose :id
    expose :inventory_formula_id
    expose :conditionable_id
    expose :conditionable_type
    expose :operator
    expose :content
  end
end
