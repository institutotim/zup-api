require 'spec_helper'

describe UserAbility do
  let(:user) { create(:user, groups: []) }

  subject { described_class.new(user) }

  context 'manage permissions' do
    context 'managing users' do
      let(:other_user) { create(:user) }
      let(:group) do
        g = create(:group)
        g.permission.update(users_full_access: true)
        g.save
        g
      end

      it 'can manage the given entity' do
        user.groups << group
        expect(subject.can?(:manage, User)).to be_truthy
        expect(subject.can?(:manage, user)).to be_truthy
        expect(subject.can?(:manage, other_user)).to be_truthy
      end

      it "can't manage the given entity" do
        expect(subject.can?(:manage, other_user)).to be_falsy
        expect(subject.can?(:edit, user)).to be_truthy
      end
    end

    context 'managing groups' do
      let(:other_group) { create(:group) }
      let(:group) { create(:group) }

      before { user.groups << group }

      it 'can manage the given group' do
        group.permission.group_edit = [other_group.id]
        group.save!
        expect(subject.can?(:edit, other_group)).to be_truthy
      end

      it "can't manage the group" do
        expect(subject.can?(:edit, other_group)).to be_falsy
      end
    end
  end

  describe 'reports items permissions' do
    let(:permission) { create(:group_permission) }
    let(:group)      { create(:group, permission: permission) }
    let(:category)   { create(:reports_category_with_statuses) }
    let(:item)       { create(:reports_item, category: category) }
    let(:other_item) { create(:reports_item) }

    before(:each) do
      user.groups.push(group)
    end

    context 'user with full access' do
      let(:permission) { create(:group_permission, reports_full_access: true) }

      it 'can send a notification' do
        expect(subject.can?(:send_notification, item)).to be_truthy
        expect(subject.can?(:send_notification, other_item)).to be_truthy
      end

      it 'can restart a notification' do
        expect(subject.can?(:restart_notification, item)).to be_truthy
        expect(subject.can?(:restart_notification, other_item)).to be_truthy
      end
    end

    context 'user in a group that can send notifications for category' do
      let(:permission) { create(:group_permission, reports_items_send_notification: [category.id]) }

      it 'can send a notification' do
        expect(subject.can?(:send_notification, item)).to be_truthy
      end

      it 'can not send a notification' do
        expect(subject.can?(:send_notification, other_item)).to be_falsy
      end
    end

    context 'user in a group that can restart notifications for category' do
      let(:permission) { create(:group_permission, reports_items_restart_notification: [category.id]) }

      it 'can restart a notification' do
        expect(subject.can?(:restart_notification, item)).to be_truthy
      end

      it 'can not restart a notification' do
        expect(subject.can?(:restart_notification, other_item)).to be_falsy
      end
    end

    context 'user in a group that can edit item for category' do
      let(:permission) do
        create(:group_permission, reports_items_edit: [category.id])
      end

      it 'can send a notification' do
        expect(subject.can?(:send_notification, item)).to be_truthy
      end

      it 'can not send a notification' do
        expect(subject.can?(:send_notification, other_item)).to be_falsy
      end

      it 'can restart a notification' do
        expect(subject.can?(:restart_notification, item)).to be_truthy
      end

      it 'can not restart a notification' do
        expect(subject.can?(:restart_notification, other_item)).to be_falsy
      end
    end

    context 'user in a group that can manage categories' do
      let(:permission) do
        create(:group_permission, manage_reports_categories: true)
      end

      it 'can send a notification' do
        expect(subject.can?(:send_notification, item)).to be_truthy
        expect(subject.can?(:send_notification, other_item)).to be_truthy
      end

      it 'can restart a notification' do
        expect(subject.can?(:restart_notification, item)).to be_truthy
        expect(subject.can?(:restart_notification, other_item)).to be_truthy
      end
    end

    context 'user in a group that can edit categories' do
      let(:permission) do
        create(:group_permission, reports_categories_edit: [category.id])
      end

      it 'can send a notification' do
        expect(subject.can?(:send_notification, item)).to be_truthy
      end

      it 'can not send a notification' do
        expect(subject.can?(:send_notification, other_item)).to be_falsy
      end

      it 'can restart a notification' do
        expect(subject.can?(:restart_notification, item)).to be_truthy
      end

      it 'can not restart a notification' do
        expect(subject.can?(:restart_notification, other_item)).to be_falsy
      end
    end
  end
end
