require 'spec_helper'

describe Reports::Item do
  let(:inventory) { build(:inventory_item) }

  context 'validations' do
    it 'should not allow description' do
      report = build(:reports_item)
      report.description = 'a' * 801

      expect(report.save).to eq(false)
      expect(report.errors).to include(:description)
    end

    context 'validations for boundary' do
      let(:item) { build(:reports_item) }
      let(:latitude) { -46.32341 }
      let(:longitude) { -23.134234 }

      before do
        item.position = Reports::Item.rgeo_factory.point(longitude, latitude)
      end

      context 'validation for boundary is enabled' do
        before do
          allow(CityShape).to receive(:validation_enabled?).and_return(true)
        end

        context 'position in boundaries' do
          before do
            allow(CityShape).to receive(:contains?)
            .and_return(true)
          end

          it 'is valid' do
            expect(item.valid?).to be_truthy
          end
        end

        context 'position not in boundaries' do
          before do
            allow(CityShape).to receive(:contains?)
                            .and_return(false)
          end

          it 'is valid' do
            expect(item.valid?).to be_falsy
          end
        end

        context 'position is nil' do
          before do
            allow(CityShape).to receive(:contains?)
                            .and_return(false)
            allow(item).to receive(:position).and_return(nil)
          end

          it 'is valid' do
            expect(item.valid?).to be_truthy
          end
        end
      end

      context 'validation for boundary is disabled' do
        before do
          allow(CityShape).to receive(:validation_enabled?).and_return(false)
        end

        context 'position not in boundaries' do
          it 'is valid' do
            expect(item.valid?).to be_truthy
          end
        end
      end
    end
  end

  context 'postal_code' do
    it "stripes everything else that isn't a number" do
      postal_code = '13456-234$%$'
      report = build(:reports_item, postal_code: postal_code)

      expect(report).to be_valid
    end

    it 'allow nil value' do
      postal_code = nil
      report = build(:reports_item, postal_code: postal_code)

      expect(report).to be_valid
    end

    it 'allow empty string' do
      postal_code = ''
      report = build(:reports_item, postal_code: postal_code)

      expect(report).to be_valid
    end
  end

  context '#address_for_exposure' do
    let(:report) { build(:reports_item, address: 'Address') }

    it 'show reports item address'  do
      expect(report.address_for_exposure).to eq('Address')
    end

    it 'show inventory item address'  do
      allow(inventory).to receive(:location) { { address: 'Inventory Address' } }

      report.inventory_item = inventory
      expect(report.address_for_exposure).to eq('Inventory Address')
    end
  end

  context '#full_address' do
    let(:report) { build(:reports_item, address: 'Address', number: '123', district: 'District', postal_code: '12345-678') }

    it 'show full address of item' do
      expect(report.full_address).to eq('Address, 123 - District, 12345-678')
    end

    it 'show item address without district' do
      report = build(:reports_item, address: 'Address', number: '123', district: nil, postal_code: '12345-678')
      expect(report.full_address).to eq('Address, 123, 12345-678')
    end

    it 'show inventory item address instead report item address' do
      allow(inventory).to receive(:location) { { address: 'Inventory Address' } }

      report.inventory_item = inventory
      expect(report.full_address).to eq('Inventory Address, 123 - District, 12345-678')
    end
  end

  it 'has relationship with inventory category through category' do
    inventory_categories = create_list(:inventory_category, 3)
    category = create(
      :reports_category_with_statuses,
      inventory_category_ids: inventory_categories.map(&:id)
    )
    item = create(:reports_item, category: category)

    expect(item.inventory_categories).to match_array(inventory_categories.to_a)
  end

  it 'has the same position of the inventory item' do
    inventory_item = create(:inventory_item)
    report = build(:reports_item)

    report.inventory_item = inventory_item
    expect(report.save).to eq(true)
    expect(report.position).to eq(inventory_item.position)
  end

  context 'status history' do
    it 'create a new entry on status history when status is created' do
      item = create(:reports_item)
      new_status = item.statuses.last
      Reports::UpdateItemStatus.new(item).set_status(new_status)

      expect(item.save!).to eq(true)
      expect(item.status_history.reload.size).to eq(2)
      expect(item.status_history.last.new_status).to eq(new_status)
    end
  end

  describe '#can_receive_feedback?' do
    let(:report) { create(:reports_item) }

    it "returns true if the report is final and the time isn't expired" do
      Reports::UpdateItemStatus.new(report).update_status!(report.category.status_categories.final.first.status)
      expect(report.can_receive_feedback?).to eq(true)
    end

    it "returns false if the report category doesn't accept feedback" do
      report.category.update!(user_response_time: nil)
      expect(report.can_receive_feedback?).to eq(false)
    end

    it 'returns false if the report is final but the time expired' do
      Reports::UpdateItemStatus.new(report).update_status!(report.category.status_categories.final.first.status)
      report.status_history
            .last
            .update!(
              created_at: \
                Time.now - report.category.user_response_time.seconds - 2.minutes
            )

      expect(report.can_receive_feedback?).to eq(false)
    end
  end

  context 'comments_count' do
    let(:report) { create(:reports_item) }

    it "it's updated when a new comment is created" do
      create(:reports_comment, item: report)
      expect(report.reload.comments_count).to eq(1)
    end
  end

  context 'protocol' do
    let(:report) { build(:reports_item) }

    it 'returns the protocol just after created' do
      report.save!
      expect(report.reload.protocol).to_not be_blank
    end
  end

  context 'versioning' do
    let(:report) { create(:reports_item) }

    it 'returns the version number 1, if no modifications were done' do
      expect(report.reload.version).to eq(1)
    end

    it 'updates the version number if an update is made' do
      report.update(address: 'Teste teste')
      expect(report.reload.version).to eq(2)
    end

    it 'updates the version number if an update is made' do
      require 'parallel'

      Parallel.each([report.id, report.id], in_threads: 2) do |report_id|
        described_class.find(report_id).update(address: "Teste teste #{rand(900)}")
      end

      expect(described_class.find(report.id).version).to eq(3)
    end
  end

  describe 'custom fields' do
    let(:category) { create(:reports_category_with_statuses) }
    let(:report) { create(:reports_item, category: category) }
    let(:custom_fields) { create_list(:reports_custom_field, 3) }

    before do
      category.update(custom_fields: custom_fields)
    end

    context 'new custom fields' do
      let(:valid_params) do
        hash = {}

        custom_fields.each do |custom_field|
          hash[custom_field.id] = 'Test text'
        end

        hash
      end

      it 'accepts custom fields configured in the category' do
        report.update(custom_fields: valid_params)
        expect(report.custom_fields).to eq(valid_params)
      end
    end

    context 'existing custom fields' do
      let(:valid_params) do
        hash = {}

        custom_fields.each do |custom_field|
          hash[custom_field.id] = 'Test text'
        end

        hash
      end

      before do
        report.update(custom_fields: valid_params)
      end

      it 'accepts custom fields configured in the category' do
        changed_params = {}

        valid_params.each do |id, _value|
          changed_params[id] = 'Changed text'
        end

        report.update(custom_fields: changed_params)
        expect(report.custom_fields).to eq(changed_params)
      end
    end
  end
end
