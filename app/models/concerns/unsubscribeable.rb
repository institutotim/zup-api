module Unsubscribeable
  extend ActiveSupport::Concern

  included do
    before_save :generate_unsubscribe_token
  end

  def generate_unsubscribe_token
    if unsubscribe_email_token.blank?
      self.unsubscribe_email_token = SecureRandom.hex
    end
  end

  def unsubscribe!
    update!(email_notifications: false)
  end

  module ClassMethods
    def unsubscribe(token)
      resource = find_by(unsubscribe_email_token: token)
      resource.unsubscribe! if resource
    end
  end
end
