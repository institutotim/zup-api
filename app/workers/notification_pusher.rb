class NotificationPusher
  include Sidekiq::Worker

  sidekiq_options queue: :high

  # Send push notification for mobile clients
  def perform(user_id, message, object_id = nil, kind = nil)
    user = User.find(user_id)

    device_type = user.device_type
    device_token = user.device_token

    normalized_data = {
      alert: message
    }

    if object_id && kind
      normalized_data = normalized_data.deep_merge(
        other: {
          kind: kind,
          object_id: object_id,
          user_id: user_id
        }
      )
    end

    if device_type == 'ios' && APNS.pem.present?
      APNS.send_notification(
        device_token, normalized_data.merge(badge: 1)
      )
    elsif device_type == 'android' && GCM.key.present?
      android_data = {
        message: normalized_data.delete(:alert)
      }

      android_data = android_data.merge(normalized_data.delete(:other))

      GCM.send_notification(
        device_token,
        android_data
      )
    end
  end
end
