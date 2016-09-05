require 'app_helper'

describe Inventory::Status do
  describe 'validates' do
    it { should validate_presence_of(:color) }
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_most(150) }
  end
end
