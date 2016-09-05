require 'spec_helper'

describe Cases::Create do
  let(:flow) { create(:flow) }
  let(:step) { flow.steps.first }
  let(:user) { create(:user) }

  before do
    step.update!(draft: true)
    flow.update!(draft: true)
    flow.publish(user)

    version = double(:version, id: 1)
    allow(flow).to receive(:version).and_return(version)
  end

  subject { described_class.new(flow, flow.steps.first, user) }

  it 'creates a case with the correct responsible_user_id' do
    kase = subject.create!
    expect(kase.responsible_user).to eq(user.id)
  end
end
