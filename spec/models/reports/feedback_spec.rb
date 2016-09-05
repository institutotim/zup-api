require 'app_helper'

describe Reports::Feedback do
  context 'kind validation' do
    %w(positive negative).each do |kind|
      it "accepts #{kind} as content" do
        feedback = build(:reports_feedback, kind: kind)
        expect(feedback.valid?).to eq(true)
        expect(feedback.errors).to be_empty
      end
    end

    it "don't accept kind that isn't in the list" do
      feedback = build(:reports_feedback, kind: 'neutral')
      expect(feedback.valid?).to eq(false)
      expect(feedback.errors).to include(:kind)
    end
  end
end
