require 'app_helper'

describe Reports::GroupItems do
  let(:user)         { create(:user) }
  let(:category)     { create(:reports_category_with_statuses) }
  let(:final_status) { create(:final_status, title: 'Final Status') }

  context '#group!' do
    let!(:report_one)  { create(:reports_item, category: category) }
    let!(:report_two)  { create(:reports_item, category: category) }
    let(:report_three) { create(:reports_item, category: category) }

    subject { described_class.new(user, [report_one, report_two]) }

    it 'group all reports items' do
      subject.group!

      report_one.reload
      report_two.reload

      expect(report_one.group_key).to eq(subject.key)
      expect(report_two.group_key).to eq(subject.key)
    end

    it 'group reports item and nested reports' do
      report_one.update(group_key: 'dbe88426703c499f6ebe6b799f5245ac')
      report_three.update(group_key: 'dbe88426703c499f6ebe6b799f5245ac')

      subject.group!

      report_one.reload
      report_two.reload
      report_three.reload

      expect(report_one.group_key).to eq(subject.key)
      expect(report_two.group_key).to eq(subject.key)
      expect(report_three.group_key).to eq(subject.key)
    end

    context 'validations' do
      let(:other_category) { create(:reports_category) }

      it 'return error when only one report is passed' do
        service = described_class.new(user, report_one)

        expect { service.group! }.to raise_error("Can't group a single report")
      end

      it 'return error when reports have different categories' do
        report_one.update(reports_category_id: other_category.id)

        expect { subject.group! }.to raise_error("Can't group reports from different categories")
      end

      it 'return error when at least one report have a final status' do
        report_one.update(reports_status_id: final_status.id)

        expect { subject.group! }.to raise_error("Can't grouped reports with final status")
      end
    end

    context 'histories' do
      it 'create a new history entry' do
        subject.group!

        history = report_one.histories.last

        expect(history).to_not be_nil
        expect(history.kind).to eq('grouped')
        expect(history.action).to eq("O relato esta agrupado com os seguintes relatos: ##{report_two.protocol}")
        expect(history.saved_changes).to_not be_nil
      end
    end
  end

  context '#ungroup!' do
    let!(:report_one) do
      create(:reports_item,
        category: category,
        group_key: 'dbe88426703c499f6ebe6b799f5245ac'
      )
    end

    let!(:report_two) { create(:reports_item, category: category) }

    subject { described_class.new(user, report_one) }

    it 'ungroup report item' do
      subject.ungroup!

      report_one.reload

      expect(report_one.group_key).to be_nil
    end

    it 'ungroup all report item avoid making a report grouped only with itself' do
      report_two.update(group_key: report_one.group_key)

      subject.ungroup!

      report_one.reload
      report_two.reload

      expect(report_one.group_key).to be_nil
      expect(report_two.group_key).to be_nil
    end

    context 'histories' do
      it 'create a new history entry' do
        subject.ungroup!

        history = report_one.histories.last

        expect(history).to_not be_nil
        expect(history.kind).to eq('ungrouped')
        expect(history.action).to eq('O relato esta não esta mais agrupado a nenhum outro relato')
        expect(history.saved_changes).to be_nil
      end
    end
  end
end
