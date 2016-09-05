require 'app_helper'

describe ResolutionState do
  describe 'validations' do
    it { should validate_presence_of(:flow) }
  end
end
