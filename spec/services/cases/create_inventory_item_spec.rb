require 'app_helper'

describe Cases::CreateInventoryItem do
  let(:user) { create(:user) }
  let(:inventory_item) { create(:inventory_item) }
  let(:inventory_item_select_field) do
    create(:field,
           field_type: 'inventory_item',
           category_inventory_id: [inventory_item.category.id])
  end
  let(:inventory_field) do
    create(:field,
           field_type: 'inventory_field',
           origin_field_id: inventory_item.category.sections[0].fields[0].id,
           field_id: inventory_item_select_field.id)
  end
  let!(:kase) { create(:case, case_steps: [case_step], initial_flow: step.flow) }
  let!(:case_step) { create(:case_step, step: step) }
  let!(:step) { create(:step_type_form, fields: [inventory_item_select_field, inventory_field]) }
  let(:fields_params) do
    [
      {
        field_id: inventory_item_select_field.id,
        value: [inventory_item.id]
      },
      {
        field_id: inventory_field.id,
        value: 'Test'
      }
    ]
  end

  before do
    inventory_field.update(step_id: step.id)
    step.update!(draft: true)
    kase.initial_flow.update!(draft: true)
    kase.initial_flow.publish(user)
    kase.update!(flow_version: kase.initial_flow.versions.last.id)
  end

  subject do
    described_class.new(case_step, user, fields_params)
  end

  describe '#prepare_fields_params' do
    it 'merge correct params inside fields_params' do
      prepared_params = subject.prepare_fields_params

      expect(
        prepared_params.select { |p| p[:field_id] == inventory_field.id }.first
      ).to include(user: user, inventory_item: inventory_item)
    end
  end

  describe '#save!' do
  end

  describe 'set_ids_for_inventory_item_fields!' do
  end
end
