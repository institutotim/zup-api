require 'app_helper'

describe Inventory::AnalysisExpressionEvaluator do
  let(:category) { create(:inventory_category_with_sections) }
  let(:analysis) { create(:inventory_analysis_with_scores, category: category) }
  let(:item) { create(:inventory_item, category: category) }
  let(:scores) { analysis.scores }
  let(:fields) { scores.map(&:field) }

  subject { described_class.new(analysis) }

  before do
    scores.each do |score|
      score.update!(content: item.represented_data.send(score.field.title))
    end

    analysis.expression = expression
    scores.reload
  end

  describe '#evaluate!' do
    context 'when the expression is invalid' do
      let(:expression) { '$aa + ((10 - 20' }

      it { expect{ subject.evaluate!(item) }.to raise_error(described_class::ExpressionInvalid) }
    end

    context 'when the expression contains not found fields' do
      let(:expression) {  "($#{fields[0].id} + $#{fields[1].id}) / $1" }

      it { expect{ subject.evaluate!(item) }.to raise_error(ActiveRecord::RecordNotFound) }
    end

    context 'when the expression is valid' do
      let(:total) { (scores[0].reload.score + scores[1].reload.score) * scores[2].reload.score }
      let(:expression) { "($#{fields[0].id} + $#{fields[1].id}) * $#{fields[2].id}" }

      xit { expect(subject.evaluate!(item)).to eq(total) }
    end
  end

  describe '#validate!' do
    context 'when the expression is invalid' do
      let(:expression) { '(10 + 20(SEN()' }

      it { expect{ subject.validate! }.to raise_error(described_class::ExpressionInvalid) }
    end

    context 'when the expression is valid' do
      let(:expression) { "($#{fields[0].id} + $#{fields[1].id}) / $#{fields[2].id}" }

      it { expect(subject.validate!).to eq(true) }
    end
  end
end
