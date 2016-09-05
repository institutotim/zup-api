require 'app_helper'

describe ChatRoom do
  describe 'associations' do
    it { should have_many(:chat_messages) }
  end

  context 'validations' do
    it { should validate_presence_of(:title) }
  end
end
