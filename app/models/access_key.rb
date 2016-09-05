class AccessKey < ActiveRecord::Base
  belongs_to :user

  SHORT_LIVED_DURATION = -> { 1.day.from_now }
  LONG_LIVED_DURATION  = -> { 2.months.from_now }

  validates :key, presence: true
  validates :user, presence: true
  validates :expires_at, presence: true

  scope :active, -> { where('expired = ? OR permanent = ?', false, true) }
  scope :expired, -> { where(expired: true) }

  before_validation :random_key
  before_validation :set_default_expires_at

  def expire!
    unless expired?
      update!(
        expired: true,
        expired_at: Time.now
      )
    end
  end

  def self.long_lived_duration
    LONG_LIVED_DURATION.call
  end

  def self.short_lived_duration
    SHORT_LIVED_DURATION.call
  end

  private

  def random_key
    self.key ||= SecureRandom.hex
  end

  def set_default_expires_at
    self.expires_at ||= AccessKey.short_lived_duration
  end
end
