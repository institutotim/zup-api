require 'app_helper'

describe ChatMessage do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:chattable) }
  end

  describe 'kind enum' do
    it 'has correct values' do
      should define_enum_for(:kind).with([:user, :system])
    end
  end

  describe 'validations' do
    describe 'presence' do
      [:chattable_id, :chattable_type, :kind, :text].each do |attr|
        it { should validate_presence_of(attr) }
      end

      context 'user chat message' do
        subject(:chat_message) { build(:chat_message, user_id: nil, kind: 0) }

        it 'validates the presence of user_id field' do
          expect(chat_message).to_not be_valid
        end
      end

      context 'system chat message' do
        subject(:chat_message) { build(:chat_message, user_id: nil, kind: 1) }

        it 'doesnt validate the presence of user_id field' do
          expect(chat_message).to be_valid
        end
      end
    end
  end
end
