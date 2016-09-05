require 'app_helper'

describe Reports::SerializeToWebhook do
  let!(:report) do
    create(:reports_item)
  end
  let!(:comments) do
    create_list(:reports_comment, 3, item: report)
  end
  let!(:image) do
    create(:report_image, item: report)
  end

  subject { described_class.new(report) }

  describe '#serialize' do
    before do
      Webhook.load_categories_from_file(
        File.join(Application.config.root, 'spec', 'support', 'webhook_categories.yml')
      )

      allow(subject).to receive(:external_category_id).and_return(100)
      allow(subject).to receive(:report?).and_return(true)
      allow(subject).to receive(:solicitation?).and_return(false)
    end

    it 'serializes correctly the report info' do
      data = subject.serialize

      expect(data).to match(
        latitude: report.position.latitude,
        longitude: report.position.longitude,
        external_category_id: 100,
        is_report: true,
        is_solicitation: false,
        description: report.description,
        address: report.address,
        number: report.number,
        district: report.district,
        postal_code: report.postal_code,
        city: report.city,
        state: report.state,
        reference: report.reference,
        country: report.country,
        uuid: report.uuid,
        comments: an_instance_of(Array),
        status: {
          name: report.status.title
        },
        images: [{
          data: Base64.encode64(image.image.read),
          :'mime-type' => 'image/png'
        }],
        user: an_instance_of(Hash),
        protocol: report.protocol,
        created_at: report.created_at
      )
    end

    it 'serializes without report images' do
      data = subject.serialize(skip_images: true)
      expect(data[:images]).to be_nil
    end
  end
end
