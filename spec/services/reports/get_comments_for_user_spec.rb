require 'app_helper'

describe Reports::GetCommentsForUser do
  let(:report) { create(:reports_item) }
  let!(:public_comment) { create(:reports_comment, :public, item: report) }
  let!(:private_comment) { create(:reports_comment, :private, item: report) }
  let!(:internal_comment) { create(:reports_comment, :internal, item: report) }

  context 'user is nil' do
    subject { described_class.new(report, nil) }

    it 'returns only public comments' do
      expect(subject.comments).to eq([public_comment])
    end
  end
end
