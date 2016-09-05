require 'app_helper'

describe Reports::ManageCategoryStatuses do
  let(:category)  { create(:reports_category) }
  let(:namespace) { create(:namespace) }

  subject { described_class.new(category) }

  let(:initial_params) do
    {
      'title' => 'Em Aberto',
      'color' => '#f8b01d',
      'initial' => true,
      'final' => false,
      'active' => true,
      'private' => false,
      'namespace_id' => namespace.id
    }
  end

  let(:in_progress_params) do
    {
      'title' => 'Em Andamento',
      'color' => '#f8b01d',
      'initial' => false,
      'final' => false,
      'active' => true,
      'private' => false,
      'namespace_id' => namespace.id
    }
  end

  let(:final_params) do
    {
      'title' => 'Concluido',
      'color' => '#78c953',
      'initial' => false,
      'final' => true,
      'active' => true,
      'private' => false,
      'namespace_id' => namespace.id
    }
  end

  let(:valid_params) do
    [initial_params, in_progress_params, final_params]
  end

  describe '#update_statuses!' do
    it 'create new status and status category' do
      subject.update_statuses!(valid_params)

      statuses = category.statuses.pluck(:title)

      expect(statuses.size).to eq(3)
      expect(statuses).to match_array(['Em Aberto', 'Em Andamento', 'Concluido'])

      status_categories = category.status_categories.pluck(:initial, :final, :namespace_id)

      expect(status_categories.size).to eq(3)
      expect(status_categories).to match_array([
        [true, false, namespace.id],
        [false, false, namespace.id],
        [false, true, namespace.id]
      ])
    end

    it 'raise an error when more one initial status is passed' do
      expect { subject.update_statuses!([initial_params, initial_params]) }.to raise_error(
        'A report status must only have a single initial status'
      )
    end

    it 'raise an error when no initial status is passed' do
      expect { subject.update_statuses!([in_progress_params]) }.to raise_error(
        'A initial and final status must be defined'
      )
    end

    it 'raise an error when no final status is passed' do
      expect { subject.update_statuses!([in_progress_params]) }.to raise_error(
        'A initial and final status must be defined'
      )
    end
  end
end
