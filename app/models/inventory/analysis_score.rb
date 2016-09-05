# encoding utf-8
class Inventory::AnalysisScore < Inventory::Base
  OPERATORS = %w(
    equal_to
    greater_than
    lesser_than
    different
    between
    includes
  )

  belongs_to :analysis, class_name: 'Inventory::Analysis', foreign_key: 'inventory_analysis_id', inverse_of: :scores
  belongs_to :field, class_name: 'Inventory::Field', foreign_key: 'inventory_field_id'

  validates :analysis, presence: true
  validates :field, presence: true
  validates :score, presence: true
  validates :operator, presence: true, inclusion: { in: OPERATORS }
  validates :content, presence: true

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
    if !super.nil? && field.use_options?
      super.map(&:to_i)
    elsif !super.nil? && super.size == 1
      super.first
    else
      super
    end
  end

  class Entity < Grape::Entity
    expose :id
    expose :inventory_analysis_id
    expose :inventory_field_id
    expose :operator
    expose :content
    expose :score
  end
end
