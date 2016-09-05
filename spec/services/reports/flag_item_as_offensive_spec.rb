require 'app_helper'

describe Reports::FlagItemAsOffensive do
  let(:user) { create(:user) }
  let(:item) { create(:reports_item) }

  subject { described_class.new(user, item) }

  describe '#flag!' do
    context 'user has not reported the item before' do
      it 'creates the flag correctly' do
        subject.flag!
        flag = Reports::OffensiveFlag.for(user, item)

        expect(flag).to_not be_nil
      end
    end

    context 'report item already reached the minimum to be marked as offensive' do
      before do
        create_list(:reports_offensive_flag,
                    Reports::FlagItemAsOffensive::MINIMUM_FLAGS_TO_MARK - 1,
                    item: item)
      end

      it 'marks item as offensive' do
        subject.flag!
        expect(item.reload.offensive).to be_truthy
      end
    end

    context 'user has already reported the item' do
      it "doesn't create another flag and raise an error" do
        subject.flag!

        expect do
          subject.flag!
        end.to raise_error(Reports::FlagItemAsOffensive::UserAlreadyReported)
      end
    end

    context 'user already reached the limit' do
      let(:other_item) { create(:reports_item) }

      before do
        Reports::FlagItemAsOffensive::MAXIMUM_REPORTS_BY_HOUR_PER_USER = 1
      end

      it "doesn't create another flag and raise an error" do
        subject.flag!

        expect do
          described_class.new(user, other_item).flag!
        end.to raise_error(Reports::FlagItemAsOffensive::UserReachedReportLimit)
      end
    end
  end

  describe '#unflag!' do
    context 'report is flagged as offensive at least once' do
      before do
        create(:reports_offensive_flag, item: item)
        item.update!(offensive: true)
      end

      it 'deletes all offensive flags' do
        subject.unflag!
        item.reload

        expect(item).to_not be_offensive
      end

      it 'unmark it as offensive' do
        subject.unflag!
        item.reload

        expect(item.offensive_flags).to be_empty
      end
    end
  end
end
