require 'spec_helper'

describe ListUsers do
  let(:group) { create(:group) }
  let(:logged_user) { create(:user) }
  let!(:users) { create_list(:user, 3, name: 'Mario Bro') }

  context 'filtering by kind' do
    let!(:services) { create_list(:service, 2) }

    it 'return only users' do
      returned_users = ListUsers.new(logged_user).fetch

      expect(returned_users).to include(*users)
      expect(returned_users).to_not include(*services)
    end

    it 'return only services' do
      returned_users = ListUsers.new(logged_user, service: true).fetch

      expect(returned_users).to include(*services)
      expect(returned_users).to_not include(*users)
    end
  end

  context 'searching by name' do
    let!(:lucas_moura) { create(:user, name: 'Lucas Moura') }

    subject(:returned_users) { described_class.new(logged_user, params).fetch }

    context 'using full text search' do
      let(:params) do
        {
          name: 'luca'
        }
      end

      it 'returns the user which has the search string as part of the name' do
        expect(returned_users).to match_array([lucas_moura])
      end
    end
  end

  context 'searching by email' do
    let(:correct_user) do
      user = users.sample
      user.update(email: 'test@gmail.com')
      user
    end

    subject { described_class.new(logged_user, valid_params) }

    context 'using full text search' do
      let(:valid_params) do
        {
          email: 'test'
        }
      end

      it 'returns only the user with part of the name' do
        users = subject.fetch
        expect(users).to match_array([correct_user])
      end
    end

    context 'when the `filter` param is true' do
      let(:valid_params) do
        {
          email: 'test@gmail.com',
          filter: true
        }
      end

      it 'returns only the user with full email' do
        users = subject.fetch
        expect(users).to match_array([correct_user])
      end
    end
  end

  context 'searching by query' do
    let!(:correct_user) { create(:user, email: 'user@mail.com') }

    context 'using email' do
      let(:valid_params) do
        {
          query: 'user'
        }
      end

      subject { described_class.new(logged_user, valid_params) }

      it 'returns only the user with part of the email' do
        users = subject.fetch
        expect(users).to match_array([correct_user])
      end
    end

    context 'using name' do
      let!(:correct_user) { create(:user, name: 'Márcos') }

      let(:valid_params) do
        {
          query: 'marco'
        }
      end

      subject { described_class.new(logged_user, valid_params) }

      it 'returns only the user with part of the name' do
        users = subject.fetch
        expect(users).to match_array([correct_user])
      end
    end

    context 'using document' do
      let!(:correct_user) { create(:user, document: '74151764720') }

      let(:valid_params) do
        {
          query: '7415176'
        }
      end

      subject { described_class.new(logged_user, valid_params) }

      it 'returns only the user with part of the document' do
        users = subject.fetch
        expect(users).to match_array([correct_user])
      end
    end
  end

  context 'searching by groups' do
    let(:correct_user) do
      user = users.sample
      user.groups << group
      user
    end

    let(:valid_params) do
      {
        groups: [group]
      }
    end

    subject { described_class.new(logged_user, valid_params) }

    it 'returns only the user with the defined group' do
      users = subject.fetch
      expect(users).to match_array([correct_user])
    end
  end

  context 'ordering search' do
    let!(:first_user) { create(:user, name: 'Aaaa') }
    let!(:last_user) { create(:user, name: 'Zzzzz') }
    let(:valid_params) do
      {
        sort: 'name',
        order: 'asc'
      }
    end

    subject { described_class.new(logged_user, valid_params) }

    it 'returns the users on the correct position' do
      returned_users = subject.fetch

      expect(returned_users).to include(first_user)
      expect(returned_users).to include(last_user)

      expect(returned_users.first.id).to eq(first_user.id)
      expect(returned_users.last.id).to eq(last_user.id)
    end
  end

  context 'permissions' do
    let(:permission) { create(:group_permission, users_edit: [group.id]) }
    let(:group_permission) { create(:group_permission, group_edit: [group.id]) }
    let!(:user_visible) { create(:user, groups: [group]) }

    subject { described_class.new(logged_user) }

    it 'returns all users when current user can manage users' do
      expected_users = *users, user_visible, logged_user

      returned_users = subject.fetch
      expect(returned_users).to match_array(expected_users)
    end

    it 'returns only users that current user can edit' do
      allow_any_instance_of(Group).to receive(:permission) { permission }

      returned_users = subject.fetch
      expect(returned_users.size).to eq 1
      expect(returned_users).to match_array(user_visible)
    end

    it 'returns all users when user can edit a group' do
      allow_any_instance_of(Group).to receive(:permission) { group_permission }

      expected_users = *users, user_visible, logged_user

      returned_users = described_class.new(logged_user).fetch
      expect(returned_users).to match_array(expected_users)
    end
  end
end
