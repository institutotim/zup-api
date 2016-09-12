require 'app_helper'

describe Reports::ManageCategory do
  let(:category)  { create(:reports_category) }

  let(:valid_params) do
    {
        title: 'Report Category',
        icon: encode64('images/valid_report_category_icon.png'),
        marker: encode64('images/valid_report_category_marker.png'),
        resolution_time_enabled: true,
        resolution_time: 172801,
        user_response_time: 86401,
        color: '#f3f3f3',
        priority: 'high',
        confidential: true,
        statuses: {
          0 =>  { title: 'Open', color: '#ff0000', initial: true, final: false, active: true, private: false },
          1 =>  { title: 'Closed', color: '#f4f4f4', final: true, initial: false, active: false, private: false }
        }
    }
  end

  describe '#create!' do
    let!(:namespaces) { create_list(:namespace, 2, default: true) }

    subject { described_class.new }

    it 'create category and settings and statuses for namespaces' do
      subject.create!(valid_params)

      category = subject.category

      expect(category.title).to eq('Report Category')
      expect(category.icon).to_not be_nil
      expect(category.marker).to_not be_nil

      expect(category.statuses.count).to eq(2)
      expect(category.status_categories.count).to eq(6)

      namespaces.each do |namespace|
        settings = category.settings.find_by(namespace_id: namespace.id)

        expect(settings.resolution_time_enabled).to be_truthy
        expect(settings.resolution_time).to eq(172801)
        expect(settings.user_response_time).to eq(86401)

        statuses = category.status_categories.where(namespace_id: namespace.id)
        expect(statuses.count).to eq(2)
      end
    end
  end

  describe '#update!' do
    let(:status)    { create(:status, title: 'In Progress') }
    let(:namespace) { create(:namespace) }

    let!(:status_category) do
      create(:reports_status_category,
        category: category,
        status: status,
        namespace: namespace
      )
    end

    subject { described_class.new(category) }

    it 'update category and settings and statuses for current namespace' do
      valid_params.merge!(
        resolution_time_enabled: false,
        resolution_time: 0,
        user_response_time: 0
      )

      subject.update!(namespace.id, valid_params)

      category.reload

      expect(category.title).to eq('Report Category')

      expect(category.statuses.pluck(:title)).to match_array(['Open', 'Closed'])
      expect(category.status_categories.count).to eq(2)

      settings = category.settings.find_by(namespace_id: namespace.id)

      expect(settings.resolution_time_enabled).to be_falsy
      expect(settings.resolution_time).to eq(0)
      expect(settings.user_response_time).to eq(0)

      statuses = category.status_categories.where(namespace_id: namespace.id)
      expect(statuses.count).to eq(2)
    end
  end
end
