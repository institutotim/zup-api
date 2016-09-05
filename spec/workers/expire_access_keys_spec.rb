require 'app_helper'

describe ExpireAccessKeys do
  let!(:key_to_be_destroyed) { create(:access_key, expired_at: 7.months.ago) }
  let!(:key_to_be_expired) { create(:access_key, expired: false, expires_at: 1.day.ago) }

  let!(:key_to_be_permanent) do
    create(:access_key,
      expired: false,
      permanent: true,
      expires_at: 1.day.ago
    )
  end

  subject { described_class.new.perform }

  it 'destroys keys older than 6 months' do
    subject
    expect(AccessKey.find_by(id: key_to_be_destroyed.id)).to be_nil
  end

  it 'expires keys older than 1 day' do
    subject
    key_to_be_expired.reload

    expect(key_to_be_expired).to be_expired
    expect(key_to_be_expired.expired_at).to_not be_blank
  end

  it 'expires keys older than 1 day' do
    subject
    key_to_be_permanent.reload

    expect(key_to_be_expired).to_not be_expired
    expect(key_to_be_expired.expired_at).to be_blank
  end
end
