# encoding: utf-8
class Inventory::Analysis < Inventory::Base
  belongs_to :category, class_name: 'Inventory::Category', foreign_key: 'inventory_category_id'
  has_many :scores, class_name: 'Inventory::AnalysisScore', foreign_key: 'inventory_analysis_id', dependent: :destroy, inverse_of: :analysis

  accepts_nested_attributes_for :scores, allow_destroy: true

  validates :expression, presence: true
  validates :title, presence: true
  validate :expression_formatter

  protected

  def expression_formatter
      Inventory::AnalysisExpressionEvaluator.new(self).validate!
    rescue Inventory::AnalysisExpressionEvaluator::ExpressionInvalid => e
      errors[:expression] << e.message
  end

  class Entity < Grape::Entity
    expose :id
    expose :title
    expose :category, using: Inventory::Category::Entity
    expose :expression
    expose :scores, using: Inventory::AnalysisScore::Entity
  end
end
