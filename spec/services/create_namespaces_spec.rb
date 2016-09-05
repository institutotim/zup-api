require 'app_helper'

describe CreateNamespace do
  let!(:category) { create(:reports_category_with_statuses) }

  let(:valid_params) { { name: 'New Namespace' } }

  subject { described_class.new }

  describe '#create!' do
    it 'create namespace and statuses for each category' do
      subject.create!(valid_params)

      namespace = subject.namespace
      statuses  = category.status_categories.where(namespace_id: namespace.id)

      expect(namespace.name).to eq('New Namespace')
      expect(category.settings.exists?(namespace_id: namespace.id)).to be_truthy
      expect(statuses.count).to eq(category.statuses.count)
    end
  end
end
