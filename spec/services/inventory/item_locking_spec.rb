require 'spec_helper'

describe Inventory::ItemLocking do
  let(:item) { create(:inventory_item) }
  let(:user) { create(:user) }

  subject { described_class.new(item, user) }

  describe '#lock!' do
    it 'locks the item' do
      subject.lock!
      item.reload
      expect(item).to be_locked
      expect(item.locker).to eq(user)
      expect(item.locked_at).to be < 1.minute.from_now
    end
  end

  describe '#unlock!' do
    before do
      item.update(locked: true)
    end

    it 'unlocks the item' do
      subject.unlock!
      item.reload
      expect(item).to_not be_locked
    end
  end

  describe '#unlock_if_expired!' do
    context 'item locked less than 1 minute ago' do
      before do
        item.update(locked: true, locked_at: 10.seconds.ago)
      end

      it "doesn't unlock" do
        expect(item).to be_locked
        subject.unlock_if_expired!
        item.reload
        expect(item).to be_locked
      end
    end

    context 'item locked more than 1 minute ago' do
      before do
        item.update(locked: true, locked_at: (1.minute + 2.seconds).ago)
      end

      it "doesn't unlock" do
        expect(item).to be_locked
        subject.unlock_if_expired!
        item.reload
        expect(item).to_not be_locked
      end
    end
  end
end
