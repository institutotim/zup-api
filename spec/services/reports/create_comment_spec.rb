require 'app_helper'

describe Reports::CreateComment do
  let(:user)   { create(:user) }
  let(:report) { create(:reports_item) }

  let(:valid_params) do
    {
      visibility: 0,
      message: 'New comment',
      author_id: user.id,
      reports_item_id: report.id
    }
  end

  subject { described_class.new(user, report) }

  context '#build' do
    it 'initialize a new comment' do
      expect(subject.comment).to be_nil

      subject.build(valid_params)
      comment = subject.comment

      expect(comment).to_not be_nil
      expect(comment.visibility).to eq(0)
      expect(comment.message).to eq('New comment')
      expect(comment.author_id).to eq(user.id)
      expect(comment.reports_item_id).to eq(report.id)
      expect(comment.new_record?).to be_truthy
    end
  end

  context '#save!' do
    it 'create a new comment' do
      subject.build(valid_params)

      expect_any_instance_of(Reports::NotifyUser).to receive(:notify_new_comment!)
      expect_any_instance_of(Reports::CreateHistoryEntry).to receive(:create).and_call_original

      subject.save!
      comment = subject.comment
      history = report.histories.last

      expect(comment.new_record?).to be_falsy
      expect(history.action).to eq('Inseriu um comentário público')
      expect(history.kind).to eq('comment')
    end
  end
end
