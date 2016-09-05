require 'spec_helper'

describe Inventory::CategoryLocking do
  let(:category) { create(:inventory_category) }
  let(:user) { create(:user) }

  subject { described_class.new(category, user) }

  describe '#lock!' do
    it 'locks the category' do
      subject.lock!
      category.reload
      expect(category).to be_locked
      expect(category.locker).to eq(user)
      expect(category.locked_at).to be < 1.minute.from_now
    end
  end

  describe '#unlock!' do
    before do
      category.update(locked: true)
    end

    it 'unlocks the category' do
      subject.unlock!
      category.reload
      expect(category).to_not be_locked
    end
  end

  describe '#unlock_if_expired!' do
    context 'category locked less than 1 minute ago' do
      before do
        category.update(locked: true, locked_at: 10.seconds.ago)
      end

      it "doesn't unlock" do
        expect(category).to be_locked
        subject.unlock_if_expired!
        category.reload
        expect(category).to be_locked
      end
    end

    context 'category locked more than 1 minute ago' do
      before do
        category.update(locked: true, locked_at: (1.minute + 2.seconds).ago)
      end

      it "doesn't unlock" do
        expect(category).to be_locked
        subject.unlock_if_expired!
        category.reload
        expect(category).to_not be_locked
      end
    end
  end
end
