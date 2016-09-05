module PasswordAuthenticable
  extend ActiveSupport::Concern

  included do
    attr_accessor :current_password, :password, :password_confirmation,
                  :resetting_password, :old_encrypted_password, :user_changing_password

    before_validation :encrypt_password
    after_create :clear_password_attributes

    validates_presence_of :password, :password_confirmation,
      if: :should_require_password_fields?
    validates :password, length: { in: 6..16 }, confirmation: true,
      if: :should_require_password_fields?

    validate :presence_of_current_password, unless: :service?
  end

  # Encrypts passwords
  def self.crypt(password, salt)
    digest = OpenSSL::Digest::SHA256.new
    Armor.digest(
      password.to_s,
      salt
    )
  end

  # Encrypts the user password
  def encrypt_password
    unless password.blank?
      unless salt
        begin
          self.salt = SecureRandom.hex
        end while self.class.find_by(salt: salt)
      end

      unless encrypted_password.blank?
        self.old_encrypted_password = encrypted_password
      end

      self.encrypted_password = \
        PasswordAuthenticable.crypt(password, salt)
    end
  end

  # After creation clear passwords
  def clear_password_attributes
    self.password = self.password_confirmation = nil
  end

  # Check if given password is the user's password
  def check_password(password_to_compare, c = nil)
    c = encrypted_password unless c

    PasswordAuthenticable.eql_time_cmp(
      c,
      PasswordAuthenticable.crypt(password_to_compare, salt)
    )
  end

  # Sets new password (and confirmation) for the user, and return it
  def generate_random_password!
    self.resetting_password = true
    self.password = self.password_confirmation = SecureRandom.hex(8)
  end

  # Generate a token for password resetting
  def generate_reset_password_token!
    token = SecureRandom.hex
    update!(reset_password_token: token)
  end

  def should_require_password_fields?
    new_record? && !ignore_password_requirement? || resetting_password
  end

  def presence_of_current_password
    permissions = UserAbility.for_user(user_changing_password || self)

    # If is an existent record
    # and the password attribute is present
    # and the current_password
    # or the informed one is inequal to current
    # and is not resetting the password
    if !permissions.can?(:manage, self) &&
       !new_record? &&
       password.present? &&
       !resetting_password &&
       current_password.blank?
      errors.add(:current_password, 'needs to be informed')
    elsif current_password.present? && !check_password(current_password, old_encrypted_password)
      errors.add(:current_password, 'isn\'t correct')
    end
  end

  module ClassMethods
    # Authenticates email and password
    def authenticate(email, password, device = :other)
      if (user = enabled.user.find_by(email: email))
        if user.check_password(password)
          user.generate_access_key!(long_lived: device == :mobile)
          return user.reload
        else
          return false
        end
      else
        return false
      end
    end

    # Starts password recovery proceedings
    # Generate a reset password token and
    # send e-mail.
    def request_password_recovery(email, from_panel = false)
      user = find_by(email: email)

      if user
        user.generate_reset_password_token!
        UserMailer.delay.send_password_recovery_instructions(user, from_panel)

        return true
      else
        return false
      end
    end

    # Resets the password
    def reset_password!(token, new_password, new_password_confirmation)
      user = find_by(reset_password_token: token)

      if user
        user.resetting_password = true

        user.update!(
          password: new_password,
          password_confirmation: new_password_confirmation,
          reset_password_token: nil
        )
      end
    end
  end

  # Compare strings with equal
  # amount of time.
  def self.eql_time_cmp(a, b)
    unless a.length == b.length
      return false
    end

    cmp = b.bytes.to_a

    result = 0
    a.bytes.each_with_index do |c, i|
      result |= c ^ cmp[i]
    end

    result == 0
  end
end
