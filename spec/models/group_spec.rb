require 'app_helper'

describe Group do
  describe 'associations' do
    it { should have_and_belong_to_many(:users) }
    it { should have_one(:permission).class_name('GroupPermission').autosave(true) }
  end

  it 'validates name' do
    group = Group.new
    expect(group).to_not be_valid
    group.errors.should include(:name)
  end

  it 'has relation with users' do
    group = create(:group)
    user = create(:user)

    group.users << user
    group.save

    group = Group.find(group.id)
    expect(group.users).to include(user)
  end

  it "isn't a guest if nothing is specified" do
    group = create(:group, guest: nil)
    expect(group.guest).to eq(false)
  end

  describe '.with_permission' do
    let(:group) { create(:group) }
    let(:groups) { create_list(:group, 10) }

    before :each do
      group.permission.manage_users = true
      group.save!
    end

    it 'returns groups where the given permission is true' do
      expect(Group.with_permission(:manage_users)).to eq(group)
    end
  end

  describe '.that_includes_permission' do
    let!(:group) { create(:group) }
    let!(:other_group) { create(:group) }

    before do
      group.permission.update(
        inventory_fields_can_edit: [2],
        inventory_fields_can_view: [2]
      )
    end

    it 'returns only the groups that has the id in permissions' do
      groups = Group.that_includes_permission(:inventory_fields_can_edit, 2)
      expect(groups).to eq([group])
    end

    it 'returns no group if none has the id' do
      groups = Group.that_includes_permission(:inventory_fields_can_edit, 3)
      expect(groups).to eq([])
    end
  end
end
