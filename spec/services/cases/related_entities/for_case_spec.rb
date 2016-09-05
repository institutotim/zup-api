require 'app_helper'

describe Cases::RelatedEntities::ForCase do
  let(:inventory_category) { create(:inventory_category) }
  let(:reports_category) { create(:reports_category_with_statuses) }
  let(:flow) { create(:flow, steps: [step]) }
  let(:step) { create(:step_type_form, fields: [inventory_item_field, reports_item_field]) }
  let(:inventory_item_field) do
    create(
      :field, field_type: 'inventory_item',
      category_report_id: nil,
      category_inventory_id: [inventory_category.id],
      origin_field_id: nil
    )
  end
  let(:reports_item_field) do
    create(
      :field, field_type: 'report_item',
      category_report_id: [reports_category.id],
      category_inventory_id: nil,
      origin_field_id: nil
    )
  end
  let(:case_step) { create(:case_step, step: step) }
  let!(:kase) { create(:case, case_steps: [case_step], initial_flow: step.flow) }

  subject { described_class.new(kase) }

  describe '#fetch_inventory_items' do
    let(:inventory_item) { create(:inventory_item, category: inventory_category) }
    let!(:case_step_data_field) do
      create(
        :case_step_data_field,
        case_step: case_step,
        field: inventory_item_field,
        value: "[#{inventory_item.id}]"
      )
    end

    it 'return all related inventory items through cases' do
      expect(subject.fetch_inventory_items).to eq([inventory_item])
    end
  end

  describe '#fetch_report_items' do
    let(:reports_item) { create(:reports_item, category: reports_category) }
    let!(:case_step_data_field) do
      create(
        :case_step_data_field,
        case_step: case_step,
        field: reports_item_field,
        value: "[#{reports_item.id}]"
      )
    end

    it 'return all related inventory items through cases' do
      expect(subject.fetch_report_items).to eq([reports_item])
    end
  end
end
