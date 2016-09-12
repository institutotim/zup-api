require 'app_helper'

describe MigrateNamespaces do
  let!(:namespace)         { Namespace.first_or_create(name: 'Namespace') }
  let!(:default_namespace) {  Namespace.first_or_create(name: 'Default', default: true) }

  let!(:group)  { create(:group, namespace: namespace) }
  let!(:user)   { create(:user, namespace: namespace) }
  let!(:report) { create(:reports_item, namespace: namespace) }
  let!(:perimeter) { create(:reports_perimeter, namespace: namespace) }
  let!(:inventory) { create(:inventory_item, namespace: namespace) }
  let!(:kase)      { create(:case, namespace: namespace) }
  let!(:chat_room) { create(:chat_room, namespace: namespace) }

  let(:status_category) { create(:reports_status_category, namespace: namespace) }

  context '#perform' do
    it 'migrate all records for the default namespace' do
      MigrateNamespaces.new.perform(namespace.id)

      expect(group.reload.namespace_id).to eq(default_namespace.id)
      expect(user.reload.namespace_id).to eq(default_namespace.id)
      expect(report.reload.namespace_id).to eq(default_namespace.id)
      expect(perimeter.reload.namespace_id).to eq(default_namespace.id)
      expect(inventory.reload.namespace_id).to eq(default_namespace.id)
      expect(kase.reload.namespace_id).to eq(default_namespace.id)
      expect(chat_room.reload.namespace_id).to eq(default_namespace.id)

      expect(Reports::CategorySetting.find_by(namespace_id: namespace.id)).to be_nil
      expect(Reports::StatusCategory.find_by(namespace_id: namespace.id)).to be_nil
    end
  end
end
