require 'spec_helper'

describe Flows::UpdateResolutionStates do
  let(:user) { create(:user) }
  let(:flow) { create(:flow) }

  context 'with valid resolution state params' do
    let(:resolution_state_params) do
      [
        {
          title: 'Test state',
          default: true,
          active: true
        }
      ]
    end

    subject { described_class.new(flow, user) }

    it 'creates the resolution state successfully' do
      subject.update!(resolution_state_params)

      resolution_state = flow.resolution_states.last
      expect(resolution_state.title).to eq(resolution_state_params.first[:title])
      expect(resolution_state.default).to be_truthy
      expect(resolution_state.draft).to be_truthy
      expect(flow.draft).to be_truthy
    end
  end
end
