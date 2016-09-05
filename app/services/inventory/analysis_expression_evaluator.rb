class Inventory::AnalysisExpressionEvaluator
  class ExpressionInvalid < StandardError; end

  OPERATIONS = {
      'equal_to' => lambda do |content, condition_content|
        content == condition_content
      end,
      'greater_than' => lambda do |content, condition_content|
        condition_content = condition_content[0] if condition_content.is_a?(Array)
        content = content[0] if content.is_a?(Array)

        content > condition_content.to_i
      end,
      'lesser_than' => lambda do |content, condition_content|
        condition_content = condition_content[0] if condition_content.is_a?(Array)
        content = content[0] if content.is_a?(Array)

        content < condition_content.to_i
      end,
      'different' => lambda do |content, condition_content|
        content != condition_content
      end,
      'between' => lambda do |content, condition_content|
        condition_content.include?(content)
      end,
      'includes' => lambda do |content, condition_content|
        if content.is_a?(String)
          content.downcase[condition_content.downcase]
        elsif content.is_a?(Array)
          (condition_content & content).any?
        end
      end
  }

  def initialize(analysis)
    @analysis = analysis
    @expression = analysis.expression
    @calculator = Dentaku::Calculator.new
  end

  def evaluate!(item)
      prepare_expression!(item)
      evaluate_expression!
    rescue RuntimeError => e
      raise ExpressionInvalid.new e.message
  end

  def validate!
    begin
      parse_variables! { |_field| '1' }
      evaluate_expression!
    rescue RuntimeError => e
      raise ExpressionInvalid.new e.message
    end

    true
  end

  private

  def prepare_expression!(item)
    parse_variables! do |field|
      scores = @analysis.scores.where(inventory_field_id: field.id)
      score_value = '0'

      scores.each do |score|
        score_value = score.score if score_satisfied?(score, item)
      end

      score_value
    end
  end

  def score_satisfied?(score, item)
    field = score.field
    content = item.represented_data.send(field.title)

    if field.use_options? && !content.is_a?(Array)
      content = [content]
    end

    OPERATIONS[score.operator].call(content, score.content)
  end

  def parse_variables!
    @expression = @expression.gsub(/\$([1-9][0-9]*)/) do |variable|
      id = variable[1..-1].to_i # Getting id. ex.: '$123' => 123
      yield Inventory::Field.find(id) if block_given?
    end
  end

  def evaluate_expression!
    @calculator.evaluate!(@expression)
  end
end
