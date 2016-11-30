require 'spec_helper'

describe Groups::CloneGroup do
  let(:group) { create(:group, name: 'ZUP') }

  subject { described_class.new(group.id) }

  describe '#clone!' do
    it 'Clone once a group' do
      new_group = subject.clone!
      expect(new_group.name).to eq 'Cópia 1 de ZUP'
    end

    it 'Clone twice a group' do
      create :group, name: 'Cópia 1 de ZUP'

      new_group = subject.clone!
      expect(new_group.name).to eq 'Cópia 2 de ZUP'
    end
  end
end
