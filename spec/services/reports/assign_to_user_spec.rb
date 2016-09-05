require 'app_helper'

describe Reports::AssignToUser do
  let(:category) { create(:reports_category_with_statuses) }
  let(:report) { create(:reports_item, category: category) }
  let(:user) { create(:user) }
  let(:user_to_assign) { create(:user) }

  subject { described_class.new(report, user) }

  describe '#assign!' do
    let(:group) { create(:group) }

    before do
      category.solver_groups = [group]
      category.save!

      report.update(assigned_group: group)
    end

    context 'user belongs to assigned_group' do
      before do
        user_to_assign.groups << group
        user_to_assign.save!
      end

      it 'assigns report to user' do
        subject.assign!(user_to_assign)
        expect(report.reload.assigned_user).to eq(user_to_assign)
      end
    end

    context 'user doesn\'t belongs to group' do
      it 'doesn\'t assign user and raise error' do
        expect { subject.assign!(user_to_assign) }.to raise_error
      end
    end

    context 'tries to assign to same user' do
      before do
        user_to_assign.groups << group
        user_to_assign.save!
        subject.assign!(user_to_assign)
      end

      it 'does nothing' do
        subject.assign!(user_to_assign)
        report.reload
        expect(Reports::ItemHistory.where(reports_item_id: report.id).count).to eq(1)
      end
    end

    context 'assigns to other group user' do
      let(:another_user_to_assign) { create(:user) }
      before do
        user_to_assign.groups << group
        user_to_assign.save!
        subject.assign!(user_to_assign)

        another_user_to_assign.groups << group
        another_user_to_assign.save!
      end

      it 'assigns user' do
        subject.assign!(another_user_to_assign)
        report.reload

        expect(report.assigned_user).to eq(another_user_to_assign)
      end
    end
  end
end
