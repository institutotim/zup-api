require 'app_helper'

describe CopyToReportsItems do
  let(:user)   { create(:user) }
  let(:report) { create(:reports_item) }

  subject { described_class.new }

  context '#perfom' do
    before(:each) do
      expect(Reports::CopyToItems).to receive(:new).with(user, report).and_call_original
    end

    it 'setup the service to copy status' do
      expect_any_instance_of(Reports::CopyToItems).to receive(:copy_status).with(
        'Comment', 0)

      subject.perform(user.id, report.id, 'status', comment: 'Comment', visibility: 0)
    end

    it 'setup the service to copy comment' do
      expect_any_instance_of(Reports::CopyToItems).to receive(:copy_comment).with(1000)

      subject.perform(user.id, report.id, 'comment', comment_id: 1000)
    end

    it 'setup the service to copy user' do
      expect_any_instance_of(Reports::CopyToItems).to receive(:copy_assigned_user)

      subject.perform(user.id, report.id, 'user')
    end

    it 'setup the service to copy group' do
      expect_any_instance_of(Reports::CopyToItems).to receive(:copy_assigned_group).with('Comment')

      subject.perform(user.id, report.id, 'group', comment: 'Comment')
    end

    it 'raise a error when invalid kind is passed' do
      expect { subject.perform(user.id, report.id, 'invalid') }.to raise_error('Invalid kind to copy')
    end
  end
end
