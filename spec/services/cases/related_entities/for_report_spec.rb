require 'app_helper'

describe Cases::RelatedEntities::ForReport do
  let(:report) { create(:reports_item) }

  subject { described_class.new(report) }

  describe '#fetch_cases' do
    let(:flow) { create(:flow, steps: [step]) }
    let(:step) { create(:step_type_form, fields: [field]) }
    let(:field) do
      create(
        :field, field_type: 'report_item',
        category_report_id: [report.reports_category_id],
        category_inventory_id: nil,
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
        value: "[#{report.id}]"
      )
    end

    it 'return all cases that contains the report' do
      expect(subject.fetch_cases).to eq([kase])
    end
  end

  describe '#fetch_report_items' do
    let(:another_report) { create(:reports_item) }
    let(:flow) { create(:flow, steps: [step]) }
    let(:step) { create(:step_type_form, fields: [field]) }
    let(:field) do
      create(
        :field, field_type: 'report_item',
        category_report_id: [report.reports_category_id],
        category_inventory_id: nil,
        origin_field_id: nil
      )
    end
    let(:field_another_report) do
      create(
        :field, field_type: 'report_item',
        category_report_id: [another_report.reports_category_id],
        category_inventory_id: nil,
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
        value: "[#{report.id}]"
      )
    end
    let!(:case_step_data_field_another_report) do
      create(
        :case_step_data_field,
        case_step: case_step,
        field: field_another_report,
        value: "[#{another_report.id}]"
      )
    end

    it 'return all cases that contains the report' do
      expect(subject.fetch_report_items).to eq([another_report])
    end
  end

  describe '#fetch_inventory_items' do
    context 'with cases containing inventory items related' do
      let(:inventory_item) { create(:inventory_item) }
      let(:flow) { create(:flow, steps: [step]) }
      let(:step) { create(:step_type_form, fields: [field]) }
      let(:field) do
        create(
          :field, field_type: 'report_item',
          category_report_id: [report.reports_category_id],
          category_inventory_id: nil,
          origin_field_id: nil
        )
      end
      let(:inventory_item_field) do
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
          value: "[#{report.id}]"
        )
      end
      let!(:case_step_data_field_inventory_item) do
        create(
          :case_step_data_field,
          case_step: case_step,
          field: inventory_item_field,
          value: "[#{inventory_item.id}]"
        )
      end

      it 'return all inventory items related through cases' do
        expect(subject.fetch_inventory_items).to eq([inventory_item])
      end
    end

    context 'with report directly associated to a inventory item' do
      let(:inventory_item) { create(:inventory_item) }

      before do
        report.update(inventory_item_id: inventory_item.id)
      end

      it 'return all inventory items related through cases' do
        expect(subject.fetch_inventory_items).to eq([inventory_item])
      end
    end
  end
end
