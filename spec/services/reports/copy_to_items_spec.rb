require 'app_helper'

describe Reports::CopyToItems do
  let(:namespace) { Namespace.first_or_create(default: true, name: 'Namespace') }
  let(:group)     { create(:group, namespace: namespace) }
  let(:user)      { create(:user, groups: [group], namespace: namespace) }
  let(:category)  { create(:reports_category_with_statuses, namespace: namespace) }
  let(:status)    { category.statuses.last }
  let(:comment)   { create(:reports_comment, item: report_one) }
  let!(:setting)  { Reports::CategorySetting.find_by(namespace: namespace, category: category) }

  let!(:report_one) do
    create(:reports_item,
      namespace: namespace,
      category: category,
      group_key: 'dbe88426703c499f6ebe6b799f5245ac',
      status: status,
      assigned_user: user,
      assigned_group: group
    )
  end

  let!(:report_two) do
    create(:reports_item,
      namespace: namespace,
      category: category,
      group_key: 'dbe88426703c499f6ebe6b799f5245ac'
    )
  end

  before(:each) do
    setting.solver_groups = [group]
    setting.save!
  end

  subject { described_class.new(user, report_one) }

  context '#copy_status' do
    it 'copy status and comment to grouped reports' do
      subject.copy_status('comment', 0)

      report_two.reload
      comment = report_two.comments.last

      expect(report_two.status).to eq(status)

      expect(comment.message).to eq('comment')
      expect(comment.visibility).to eq(0)
      expect(comment.author).to eq(user)
    end
  end

  context '#copy_comment' do
    it 'copy comment to grouped reports' do
      subject.copy_comment(comment.id)

      new_comment = report_two.comments.last

      expect(new_comment.message).to eq(comment.message)
      expect(new_comment.visibility).to eq(comment.visibility)
      expect(new_comment.author).to eq(comment.author)
    end
  end

  context '#copy_assigned_user' do
    it 'copy assigned user to grouped reports' do
      subject.copy_assigned_user

      report_two.reload
      expect(report_two.assigned_user).to eq(user)
    end
  end

  context '#copy_assigned_group' do
    it 'copy assigned group to grouped reports' do
      subject.copy_assigned_group

      report_two.reload
      expect(report_two.assigned_group).to eq(group)
    end
  end
end
