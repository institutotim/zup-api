# This worker is responsible to clear very old access keys
# and mark old access keys as expired
class ExpireAccessKeys
  include Sidekiq::Worker

  sidekiq_options queue: :medium

  def perform
    # Remove very old access keys, expired more than 6 months ago
    AccessKey.where('expired_at < ?', 6.months.ago).destroy_all

    # Expire old access_keys
    AccessKey.where('expired = ? AND expires_at < ? AND permanent = ?', false, Time.now, false)
             .update_all(expired: true, expired_at: Time.now)
  end
end
