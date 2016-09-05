require 'spec_helper'

describe Reports::UpdateItemStatus do
  let(:user)      { create(:user) }
  let(:category)  { create(:reports_category_with_statuses) }
  let(:status)    { create(:status) }

  let!(:status_category) do
    create(:reports_status_category, status: status, category: category)
  end

  subject { described_class.new(item, user) }

  describe '#set_status' do
    let(:item) { create(:reports_item, category: category) }

    it 'sets the item status to given status' do
      subject.set_status(status)
      expect(item.status).to eq(status)
    end

    it 'builds a new history entry for status' do
      subject.set_status(status)
      expect(item.status_history.last.new_status).to eq(status)
    end

    it 'sets the `resolved_at` if the status is final' do
      category.status_categories.find_by(reports_status_id: status.id).update(final: true)
      subject.set_status(status)
      expect(item.resolved_at).to_not be_blank
    end
  end

  describe '#update_status!' do
    let(:item) { create(:reports_item, category: category) }

    context 'valid status from same category' do
      it "updates the item's status" do
        subject.update_status!(status)

        item.reload
        expect(item.status).to eq(status)
      end
    end

    context 'valid status with no relation with the company' do
      let(:different_status) { create(:status) }

      it 'raises an error' do
        expect do
          subject.update_status!(different_status)
        end.to raise_error(/Status doesn't belongs to category/)
      end
    end

    context 'create case when the status has `create_case` setted to true' do
      let(:conductor) { create(:user) }
      before do
        flow = create(:flow, initial: true, status: 'active', steps: [build(:step_type_form)])
        flow.publish(user)

        Reports::StatusCategory.find_by(
          status: status,
          category: category
        ).update(flow_id: flow.id)
      end

      it "updates the item's status" do
        subject.case_conductor = conductor
        subject.update_status!(status)

        updated_item = Reports::Item.find(item.id)
        expect(updated_item.case).to_not be_blank
        expect(updated_item.case.case_steps.first.responsible_user).to eq(conductor)
        expect(updated_item.case.source_reports_category).to eq(item.category)
        expect(updated_item.case.responsible_user).to eq(conductor.id)
      end

      it "update item's assigned_user" do
        subject.case_conductor = conductor
        subject.update_status!(status)

        item.reload
        expect(item.assigned_user).to eq(conductor)
      end
    end
  end
end
