require 'spec_helper'

describe BuildPermissions do
  let(:full_permissions) do
    create(:group_permission,
      :full_permissions,
      can_execute_step: []
    )
  end

  let(:other_permissions) do
    create(:group_permission,
      flow_can_delete_all_cases: [3, 51, 52],
      flow_can_execute_all_steps: [53],
      inventories_items_edit: [11, 54, 55, 56],
      inventories_items_delete: [57],
      reports_items_delete: [58],
      reports_items_create: [59, 60],
      reports_items_alter_status: [61],
      business_reports_view: [27, 62, 63],
      can_execute_step: [64]
    )
  end

  context 'user' do
    let(:group_one) { create(:group, permission: full_permissions) }
    let(:group_two) { create(:group, permission: other_permissions) }
    let(:user)      { create(:user, groups: [group_one, group_two]) }

    subject { described_class.new(user).permissions }

    context 'build correct permissions' do
      it { expect(subject.manage_flows).to be_truthy }
      it { expect(subject.users_full_access).to be_truthy }
      it { expect(subject.groups_full_access).to be_truthy }
      it { expect(subject.manage_config).to be_truthy }
      it { expect(subject.panel_access).to be_truthy }
      it { expect(subject.inventories_formulas_full_access).to be_truthy }
      it { expect(subject.inventories_full_access).to be_truthy }
      it { expect(subject.reports_full_access).to be_truthy }
      it { expect(subject.manage_reports_categories).to be_truthy }
      it { expect(subject.business_reports_edit).to be_truthy }
      it { expect(subject.manage_services).to be_truthy }

      it { expect(subject.flow_can_view_all_steps).to eq([1]) }
      it { expect(subject.flow_can_execute_all_steps).to eq([2, 53]) }
      it { expect(subject.flow_can_delete_all_cases).to eq([3, 51, 52]) }
      it { expect(subject.flow_can_delete_own_cases).to eq([4]) }
      it { expect(subject.can_view_step).to eq([5]) }
      it { expect(subject.can_execute_step).to eq([64]) }
      it { expect(subject.group_edit).to eq([7]) }
      it { expect(subject.group_read_only).to eq([8]) }
      it { expect(subject.users_edit).to eq([9]) }
      it { expect(subject.inventories_items_create).to eq([10]) }
      it { expect(subject.inventories_items_edit).to eq([11, 54, 55, 56]) }
      it { expect(subject.inventories_items_delete).to eq([12, 57]) }
      it { expect(subject.inventories_items_read_only).to eq([13]) }
      it { expect(subject.inventories_categories_edit).to eq([14]) }
      it { expect(subject.reports_items_read_public).to eq([15]) }
      it { expect(subject.reports_items_read_private).to eq([16]) }
      it { expect(subject.reports_items_create).to eq([17, 59, 60]) }
      it { expect(subject.reports_items_edit).to eq([18]) }
      it { expect(subject.reports_items_delete).to eq([19, 58]) }
      it { expect(subject.reports_items_forward).to eq([20]) }
      it { expect(subject.reports_items_create_internal_comment).to eq([21]) }
      it { expect(subject.reports_items_create_comment).to eq([22]) }
      it { expect(subject.reports_items_alter_status).to eq([23, 61]) }
      it { expect(subject.reports_items_send_notification).to eq([24]) }
      it { expect(subject.reports_items_restart_notification).to eq([25]) }
      it { expect(subject.reports_categories_edit).to eq([26]) }
      it { expect(subject.business_reports_view).to eq([27, 62, 63]) }
    end

    context 'if array-typed column value is nil' do
      before do
        allow_any_instance_of(GroupPermission).to receive(:reports_items_read_private).and_return(nil)
      end

      it 'returns array anyway' do
        expect(subject.reports_items_read_private).to eq([])
      end
    end
  end

  context 'service' do
    let(:permissions) { create(:group_permission, :full_permissions) }
    let(:service) { create(:service, permission: permissions) }

    subject { described_class.new(service).permissions }

    context 'build correct permissions' do
      it { expect(subject.manage_flows).to be_truthy }
      it { expect(subject.users_full_access).to be_truthy }
      it { expect(subject.groups_full_access).to be_truthy }
      it { expect(subject.manage_config).to be_truthy }
      it { expect(subject.panel_access).to be_truthy }
      it { expect(subject.inventories_formulas_full_access).to be_truthy }
      it { expect(subject.inventories_full_access).to be_truthy }
      it { expect(subject.reports_full_access).to be_truthy }
      it { expect(subject.manage_reports_categories).to be_truthy }
      it { expect(subject.business_reports_edit).to be_truthy }
      it { expect(subject.manage_services).to be_truthy }

      it { expect(subject.flow_can_view_all_steps).to eq([1]) }
      it { expect(subject.flow_can_execute_all_steps).to eq([2]) }
      it { expect(subject.flow_can_delete_all_cases).to eq([3]) }
      it { expect(subject.flow_can_delete_own_cases).to eq([4]) }
      it { expect(subject.can_view_step).to eq([5]) }
      it { expect(subject.can_execute_step).to eq([6]) }
      it { expect(subject.group_edit).to eq([7]) }
      it { expect(subject.group_read_only).to eq([8]) }
      it { expect(subject.users_edit).to eq([9]) }
      it { expect(subject.inventories_items_create).to eq([10]) }
      it { expect(subject.inventories_items_edit).to eq([11]) }
      it { expect(subject.inventories_items_delete).to eq([12]) }
      it { expect(subject.inventories_items_read_only).to eq([13]) }
      it { expect(subject.inventories_categories_edit).to eq([14]) }
      it { expect(subject.reports_items_read_public).to eq([15]) }
      it { expect(subject.reports_items_read_private).to eq([16]) }
      it { expect(subject.reports_items_create).to eq([17]) }
      it { expect(subject.reports_items_edit).to eq([18]) }
      it { expect(subject.reports_items_delete).to eq([19]) }
      it { expect(subject.reports_items_forward).to eq([20]) }
      it { expect(subject.reports_items_create_internal_comment).to eq([21]) }
      it { expect(subject.reports_items_create_comment).to eq([22]) }
      it { expect(subject.reports_items_alter_status).to eq([23]) }
      it { expect(subject.reports_items_send_notification).to eq([24]) }
      it { expect(subject.reports_items_restart_notification).to eq([25]) }
      it { expect(subject.reports_categories_edit).to eq([26]) }
      it { expect(subject.business_reports_view).to eq([27]) }
    end
  end
end
