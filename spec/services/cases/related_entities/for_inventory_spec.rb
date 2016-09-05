require 'app_helper'

describe Cases::RelatedEntities::ForInventory do
  let(:inventory_item) { create(:inventory_item) }

  subject { described_class.new(inventory_item) }

  describe '#fetch_cases' do
    let(:flow) { create(:flow, steps: [step]) }
    let(:step) { create(:step_type_form, fields: [field]) }
    let(:field) do
      create(
        :field, field_type: 'inventory_item',
        category_report_id: nil,
        category_inventory_id: [inventory_item.inventory_category_id],
        origin_field_id: nil
      )
    end
    let(:case_step) { create(:case_step, step: step) }
    let!(:kase) { create(:case, case_steps: [case_step], initial_flow: step.flow) }
    let!(:case_step_data_field) do
      create(
        :case_step_data_field,
        case_step: case_step,
        field: field,
        value: "[#{inventory_item.id}]"
      )
    end

    it 'return all cases that contains the inventory_item' do
      expect(subject.fetch_cases).to eq([kase])
    end
  end

  describe '#fetch_inventory_items' do
    let(:another_inventory_item) { create(:inventory_item) }
    let(:flow) { create(:flow, steps: [step]) }
    let(:step) { create(:step_type_form, fields: [field]) }
    let(:field) do
      create(
        :field, field_type: 'inventory_item',
        category_report_id: nil,
        category_inventory_id: [inventory_item.inventory_category_id],
        origin_field_id: nil
      )
    end
    let(:field_another_inventory_item) do
      create(
        :field, field_type: 'inventory_item',
        category_report_id: nil,
        category_inventory_id: [another_inventory_item.inventory_category_id],
        origin_field_id: nil
      )
    end
    let(:case_step) { create(:case_step, step: step) }
    let!(:kase) { create(:case, case_steps: [case_step], initial_flow: step.flow) }
    let!(:case_step_data_field) do
      create(
        :case_step_data_field,
        case_step: case_step,
        field: field,
        value: "[#{inventory_item.id}]"
      )
    end
    let!(:case_step_data_field_another_report) do
      create(
        :case_step_data_field,
        case_step: case_step,
        field: field_another_inventory_item,
        value: "[#{another_inventory_item.id}]"
      )
    end

    it 'return all related inventory items through cases' do
      expect(subject.fetch_inventory_items).to eq([another_inventory_item])
    end
  end

  describe '#fetch_reports_items' do
    context 'with cases containing inventory items related' do
      let(:report_item) { create(:reports_item) }
      let(:flow) { create(:flow, steps: [step]) }
      let(:step) { create(:step_type_form, fields: [field]) }
      let(:report_item_field) do
        create(
          :field, field_type: 'report_item',
          category_report_id: [report_item.reports_category_id],
          category_inventory_id: nil,
          origin_field_id: nil
        )
      end
      let(:field) do
        create(
          :field, field_type: 'inventory_item',
          category_report_id: [],
          category_inventory_id: [inventory_item.inventory_category_id],
          origin_field_id: nil
        )
      end
      let(:case_step) { create(:case_step, step: step) }
      let!(:kase) { create(:case, case_steps: [case_step], initial_flow: step.flow) }
      let!(:case_step_data_field) do
        create(
          :case_step_data_field,
          case_step: case_step,
          field: field,
          value: "[#{inventory_item.id}]"
        )
      end
      let!(:case_step_data_field_report_item) do
        create(
          :case_step_data_field,
          case_step: case_step,
          field: report_item_field,
          value: "[#{report_item.id}]"
        )
      end

      it 'return all inventory items related through cases' do
        expect(subject.fetch_report_items).to eq([report_item])
      end
    end
  end
end
