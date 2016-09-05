require 'app_helper'

describe AccessKey do
  let(:access_key) { create(:access_key) }
  let(:expired_access_key) { create(:expired_access_key) }
  let(:user) { create(:user) }

  it 'generates a random string when creating' do
    AccessKey.create(
      user: user
    ).key.should_not be_blank
  end

  it 'active scope should return only not expired access keys' do
    expect(AccessKey.active).to include(access_key)
  end

  it 'sets expires at to the short lived duration as default' do
    allow(Time).to receive(:now).and_return(
      Time.parse('Feb 24 2015')
    )

    access_key = AccessKey.new
    access_key.valid?

    expect(access_key.expires_at).to eq(AccessKey.short_lived_duration)
  end

  describe '#expire!' do
    it 'marks the access key as expired' do
      access_key.expire!
      expect(access_key).to be_expired
      expect(access_key.expired_at).to_not be_blank
    end
  end

  describe '.long_lived_duration' do
    subject { described_class }

    it 'returns a date' do
      expect(subject.long_lived_duration).to be_an_instance_of(ActiveSupport::TimeWithZone)
    end
  end

  describe '.short_lived_duration' do
    subject { described_class }

    it 'returns a date' do
      expect(subject.short_lived_duration).to be_an_instance_of(ActiveSupport::TimeWithZone)
    end
  end
end
