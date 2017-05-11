require 'app_helper'

describe User do
  describe 'associations' do
    it { should have_many(:access_keys) }
    it { should have_many(:cases_log_entries) }
    it { should have_many(:cases_log_entries_as_before_user).class_name('CasesLogEntry').with_foreign_key(:before_user_id) }
    it { should have_many(:cases_log_entries_as_after_user).class_name('CasesLogEntry').with_foreign_key(:after_user_id) }
    it { should have_many(:flows).class_name('Flow').with_foreign_key(:created_by_id) }
    it { should have_many(:cases).class_name('Case').with_foreign_key(:created_by_id) }
    it { should have_many(:reports).class_name('Reports::Item').with_foreign_key(:user_id) }
    it { should have_many(:feedbacks).class_name('Reports::Feedback') }
    it { should have_and_belong_to_many(:groups) }
    it { should have_many(:groups_permissions).class_name('GroupPermission').through(:groups).source(:permission) }
    it { should have_many(:chat_messages) }
  end

  describe 'validations' do
    let(:user) { build(:user) }

    context 'default (without from_webhook)' do
      describe 'presence' do
        [:name, :email, :document, :namespace].each do |field|
          it { should validate_presence_of(field) }
        end
      end

      describe 'uniqueness' do
        it { should validate_uniqueness_of(:email) }
      end

      describe 'password length' do
        it 'has at least 6 chars' do
          user.password = user.password_confirmation = '12345'
          user.save
          expect(user.errors).to include(:password)
        end

        it 'has 16 chars length at maximum' do
          user.password = user.password_confirmation = '12345678901234567'
          user.save
          expect(user.errors).to include(:password)
        end
      end

      describe 'name length' do
        it 'has at least 6 chars' do
          user.password = user.password_confirmation = '12345'
          expect(user).to_not be_valid
          expect(user.errors).to include(:password)
        end
      end

      describe 'email format' do
        %w(estevao@gmail estevao!2#!@#@fadsf@gmail.com).each do |invalid_email|
          it "isn't allowed invalid email like '#{invalid_email}' to be registered" do
            user.email = invalid_email
            user.save
            expect(user.errors).to include(:email)
          end
        end

        %w(test+taggedemail@gmail.com user@prefeitura.gov.sp.br user_testing@gmail.com user_@gmail.com).each do |valid_email|
          it "is allowed valid email like '#{valid_email}' to be registered" do
            user.email = valid_email
            expect(user).to be_valid
          end
        end
      end

      describe 'password confirmation' do
        it 'is not allowed diferent values between `password` and `password_confirmation`' do
          user.password = '123456'
          user.password_confirmation = '654321'

          expect(user).to_not be_valid
          expect(user.errors).to include(:password_confirmation)
        end
      end

      describe 'document' do
        let(:exists_user) { create(:user) }

        it 'is not allowed duplicity' do
          user.document = exists_user.document

          expect(user).to_not be_valid
          expect(user.errors).to include(:document)
        end
      end
    end

    context 'from_webhook' do
      let(:user) { build(:user, from_webhook: true) }

      describe 'presence' do
        [:encrypted_password, :phone, :document, :address, :postal_code, :district, :city].each do |field|
          it "doesnt validate presence of #{field}" do
            user.send("#{field}=", nil)
            expect(user).to be_valid
          end
        end
      end
    end
  end

  context 'password encryptation' do
    let(:user) do
      build(:user,
        email: 'test@gmail.com',
        password: '123456',
        password_confirmation: '123456'
      )
    end

    it 'encrypts password before validation' do
      user.valid?
      user.encrypted_password.should_not be_blank
      user.should be_valid
    end

    it 'generates a random salt for the user' do
      user.valid?
      user.salt.should_not be_blank
    end

    it "doens't allow the leave the password blank on creation" do
      user.password = ''
      user.password_confirmation = ''
      expect(user.valid?).to eq(false)
      expect(user.errors.messages).to include(:password, :password_confirmation)
    end

    it 'allows password blank if the record already exists' do
      user.save
      user.password = ''
      user.password_confirmation = ''
      expect(user.valid?).to eq(true)
    end

    it "blank password fields don't update the password" do
      user.save
      current_password = user.encrypted_password
      user.password_confirmation = user.password = ''
      user.save
      expect(user.encrypted_password).to eq(current_password)
    end
  end

  context 'authentication' do
    let(:user) { create(:user, password: '123456') }
    let(:service) { create(:service, email: 'service@mail.com', password: '123456') }

    describe '#check_password' do
      it 'returns true if the passwords checks' do
        expect(user.check_password('123456')).to be_truthy
      end

      it 'returns false if the passwords are different' do
        expect(user.check_password('wrongpassword')).to be_falsy
      end
    end

    describe '.authenticate' do
      it 'returns true if the authentication is successful' do
        User.authenticate(user.email, '123456').should eq(user)
      end

      it 'returns false if the password is wrong' do
        User.authenticate(user.email, 'wrongpass').should be_falsy
      end

      it 'returns false if the username is wrong' do
        User.authenticate('wronguseremail', '123456').should be_falsy
      end

      it 'returns false if the user is disabled' do
        user.disable!
        User.authenticate(user.email, '123456').should be_falsy
      end

      it 'returns false when a service is trying to authenticate' do
        User.authenticate(service.email, '123456').should be_falsy
      end

      it 'generates a long lived token if device is mobile' do
        allow_any_instance_of(User).to \
          receive(:generate_access_key!).and_return(true)

        found_user = User.authenticate(user.email, '123456', :mobile)
        expect(found_user).to have_received(:generate_access_key!)
                                .with(long_lived: true)
      end
    end
  end

  context 'generating a new access key' do
    describe '#generate_access_key!' do
      let(:user) { create(:user) }
      let(:service) { create(:service) }

      it 'creates a new key' do
        new_key = user.generate_access_key!
        new_key.should be_a(AccessKey)

        user.last_access_key.should == new_key.key
      end

      it 'creates a long lived key if true' do
        new_key = user.generate_access_key!(long_lived: true)
        new_key.should be_a(AccessKey)

        expect(new_key.expires_at).to be > 1.day.from_now
        expect(new_key.permanent).to be_falsy
      end

      it 'creates a long lived key if true' do
        new_key = service.generate_access_key!
        new_key.should be_a(AccessKey)

        expect(new_key.permanent).to be_truthy
      end
    end
  end

  describe '#generate_random_password!' do
    let(:user) { build(:user, password: nil, password_confirmation: nil) }

    it 'generates new password for the user' do
      user.generate_random_password!
      expect(user.password).to_not be_blank
      expect(user.password_confirmation).to_not be_blank
    end
  end

  context 'password recovery' do
    let(:user) { create(:user) }

    context 'requesting and generating tokens' do
      describe '#generate_reset_password_token!' do
        it 'generates a new reset_password_token for the user' do
          expect(user.reset_password_token).to be_blank
          expect(user.generate_reset_password_token!).to be(true)
          expect(user.reload.reset_password_token).to_not be_blank
        end
      end

      describe '.request_password_recovery' do
        it 'generates a new password recovery token for user with given email' do
          expect(user.reset_password_token).to be_blank
          expect(User.request_password_recovery(user.email)).to be(true)
          expect(user.reload.reset_password_token).to_not be_blank
        end
      end
    end

    describe '.reset_password' do
      let(:pass) { 'changedpass' }

      subject do
        User.reset_password!(user.reset_password_token, pass, pass)
      end

      before do
        user.generate_reset_password_token!
        subject
        user.reload
      end

      it 'resets the user password' do
        expect(user.check_password('changedpass')).to be_truthy
      end

      it 'set reset_password_token to nil' do
        expect(user.reset_password_token).to be_nil
      end
    end
  end

  context 'token authentication' do
    let(:user) { create(:user) }
    let(:service) { create(:service) }

    describe '.authorize' do
      it 'returns the user if the given token is valid' do
        result = User.authorize(user.last_access_key)
        expect(result).to eq(user)
      end

      it 'returns the user if the given token is valid' do
        result = User.authorize(service.last_access_key)
        expect(result).to eq(service)
      end
    end
  end

  it 'has relation with groups' do
    user = create(:user)
    group = create(:group)

    user.groups << group
    user.save

    user = User.find(user.id)
    expect(user.groups).to include(group)
  end

  describe '#guest?' do
    it 'returns false for normal records' do
      user = create(:user)
      expect(user.guest?).to eq(false)

      user = User::Guest.new
      expect(user.guest?).to eq(true)
    end
  end

  context 'changing the password' do
    it 'to change the password you need to provide the current password' do
      allow_any_instance_of(UserAbility).to \
        receive(:can?).with(:manage, User).and_return(false)
      user = create(:user)
      user.current_password = '1234'
      user.password = '123456'
      user.password_confirmation = '123456'
      expect(user.valid?).to eq(false)
      expect(user.errors.messages).to include(:current_password)
    end

    it "if he user can manage users, he doesn't need to provide the current password" do
      allow_any_instance_of(UserAbility).to \
        receive(:can?).with(:manage, User).and_return(true)
      user = create(:user)
      user.password = '123456'
      user.password_confirmation = '123456'
      expect(user.valid?).to eq(true)
    end

    it 'changes if the password is the same' do
      user = create(:user, password: 'foobar')

      expect(user.check_password('foobar')).to eq(true)

      user.current_password = 'foobar'
      user.password = '123456'
      user.password_confirmation = '123456'

      expect(user.save).to eq(true)

      user.reload
      expect(user.check_password('123456')).to eq(true)
    end
  end

  describe 'permissions' do
    let(:group1) do
      group = create(:group)
      group.permission.update(inventories_categories_edit: [1, 3], users_full_access: true)
      group
    end
    let(:group2) do
      group = create(:group)
      group.permission.update(inventories_categories_edit: [3, 9], users_full_access: false)
      group
    end
    let(:user) { create(:user, groups: [group1, group2]) }

    it "merge all user group's permissions" do
      expect(user.permissions.to_h).to include(
        inventories_categories_edit: [1, 3, 9],
        users_full_access: true
      )
    end
  end

  describe '#disable!' do
    subject { create(:user) }

    it 'disables the user' do
      subject.disable!
      expect(subject.reload).to be_disabled
    end
  end

  describe '#enable!' do
    subject { create(:user, disabled: true) }

    it 'enables the user' do
      subject.enable!
      expect(subject.reload).to_not be_disabled
    end
  end
end
