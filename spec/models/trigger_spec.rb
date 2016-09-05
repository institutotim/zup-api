require 'app_helper'

describe Trigger do
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:action_type) }
    it { should validate_presence_of(:action_values) }
    it { should validate_presence_of(:trigger_conditions) }
    it { should validate_length_of(:title).is_at_most(100) }
    it { should validate_inclusion_of(:action_type).in_array(%w{enable_steps disable_steps finish_flow transfer_flow}) }
  end
end
