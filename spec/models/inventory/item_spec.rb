require 'app_helper'

describe Inventory::Item do
  context 'position' do
    let(:item) { create(:inventory_item) }

    it "updates the item's position with data of localization" do
      item.data.each do |data|
        next unless data.field.location

        if data.field.title == 'latitude'
          data.content = '51.5033630'
        elsif data.field.title == 'longitude'
          data.content = '-0.1276250'
        elsif data.field.title == 'address'
          data.content = 'Cool Street'
        end
      end

      item.save

      expect(item.position).to_not be_blank
      expect(item.position.latitude).to eq(51.5033630)
      expect(item.position.longitude).to eq(-0.1276250)
      expect(item.address).to eq('Cool Street')
    end

    context 'validations for boundary' do
      let(:item) { build(:inventory_item) }
      let(:latitude) { -46.32341 }
      let(:longitude) { -23.134234 }

      before do
        item.position = Inventory::Item.rgeo_factory.point(longitude, latitude)
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

  context 'validations' do
    describe 'status' do
      context 'when category requires item status' do
        let(:category) { create(:inventory_category, require_item_status: true) }

        context 'with status empty' do
          let(:item) { build(:inventory_item, status: nil, category: category) }

          it 'validate the presence the status' do
            expect(item.valid?).to be_falsy
            expect(item.errors).to include(:status)
          end
        end

        context 'with status full' do
          let(:item) { build(:inventory_item, :with_status, category: category) }

          it "don't validate the presence the status" do
            expect(item.valid?).to be_truthy
          end
        end
      end

      context "when category don't requires item status" do
        let(:category) { create(:inventory_category, require_item_status: false) }
        let(:item) { build(:inventory_item, status: nil, category: category) }

        it 'validate the presence the status' do
          expect(item.valid?).to be_truthy
        end
      end
    end
  end

  context 'when has a field use_as_title' do
    let!(:category) { create(:inventory_category) }
    let!(:field) { create(:inventory_field, section: category.sections.first, use_as_title: true, kind: 'text') }
    let(:item) { create(:inventory_item, category: category) }

    it "title is the field's content" do
      expect(
        item.represented_data.send(field.title)
      ).to eq(item.title)
    end
  end

  describe '#generate_title' do
    let(:category) { create(:inventory_category) }

    let!(:exists_field) do
      create(
        :inventory_field,
        section: category.sections.sample,
        options: { label: 'Title' }
      )
    end

    let!(:field) do
      build(
        :inventory_field,
        section: category.sections.sample,
        options: { label: 'Title' }
      )
    end

    it 'generate the title with number' do
      exists_field.send(:generate_title)
      exists_field.save

      expect(field.send(:generate_title)).to be_truthy
      expect(field.title).to eq 'field_title_1'
    end
  end
end
